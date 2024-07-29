/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.course.web.action.admin

import org.beangle.commons.activation.MediaTypes
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.excel.schema.ExcelSchema
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.doc.transfer.importer.ImportSetting
import org.beangle.doc.transfer.importer.listener.ForeignerListener
import org.beangle.event.bus.{DataEvent, DataEventBus}
import org.beangle.web.action.annotation.response
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.{ExportSupport, ImportSupport, RestfulAction}
import org.openurp.base.edu.model.{Course, CourseJournal, CourseJournalHour}
import org.openurp.base.model.Project
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.{CourseTag, CourseType, ExamMode, TeachingNature}
import org.openurp.edu.course.web.helper.{CourseJournalImportListener, CourseJournalPropertyExtractor}
import org.openurp.starter.web.support.ProjectSupport

import java.io.{ByteArrayInputStream, ByteArrayOutputStream}
import java.time.LocalDate
import scala.collection.SortedMap

/** 课程日志
 */
class JournalAction extends RestfulAction[CourseJournal], ProjectSupport, ExportSupport[CourseJournal], ImportSupport[CourseJournal] {

  var databus: DataEventBus = _

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departments", departs)
    put("project", project)
    put("grades", entityDao.findBy(classOf[Grade], "project" -> project).sortBy(_.code).reverse)
    forward()
  }

  override protected def editSetting(entity: CourseJournal): Unit = {
    given project: Project = getProject

    put("tags", codeService.get(classOf[CourseTag]))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("courseTypes", getCodes(classOf[CourseType]))
    put("examModes", getCodes(classOf[ExamMode]))
    put("departments", getDeparts)

    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    val grades = entityDao.search(query)
    put("grades", SortedMap.from(grades.map(x => (x.beginOn.toString, x.beginOn.toString)).sortBy(_._1).reverse))
    super.editSetting(entity)
  }

  override protected def saveAndRedirect(journal: CourseJournal): View = {
    given project: Project = getProject

    val teachingNatures = getCodes(classOf[TeachingNature])
    teachingNatures foreach { ht =>
      val creditHour = getInt("creditHour" + ht.id)
      journal.hours find (h => h.nature == ht) match {
        case Some(hour) =>
          if (creditHour.isEmpty) {
            journal.hours -= hour
          } else {
            hour.creditHours = creditHour.getOrElse(0)
          }
        case None =>
          if (creditHour.nonEmpty) {
            val newHour = new CourseJournalHour(journal, ht, creditHour.getOrElse(0))
            journal.hours += newHour
          }
      }
    }
    val orphan = journal.hours.filter(x => !teachingNatures.contains(x.nature))
    journal.hours --= orphan
    journal.tags.clear()
    journal.tags.addAll(entityDao.find(classOf[CourseTag], getIntIds("tag")))
    entityDao.saveOrUpdate(journal)

    //计算journals的结束日期
    val jq = OqlBuilder.from(classOf[CourseJournal], "j")
    jq.where("j.course=:course", journal.course)
    jq.orderBy("j.beginOn")
    val journals = entityDao.search(jq)
    if (journals.size > 1) {
      var i = 0
      while (i < journals.length - 1) { //最后一个不处理
        val j = journals(i)
        val jNext = journals(i + 1)
        j.endOn = Some(jNext.beginOn.minusMonths(1))
        i += 1
      }
      entityDao.saveOrUpdate(journals)
    }
    //last one
    if (journal.endOn.isEmpty) {
      val course = entityDao.get(classOf[Course], journal.course.id)
      if (journal.enName.nonEmpty) {
        course.enName = journal.enName
      }
      course.name = journal.name
      entityDao.saveOrUpdate(course)
      databus.publish(DataEvent.update(course))
    }
    databus.publish(DataEvent.update(journal))
    super.saveAndRedirect(journal)
  }

  override def getQueryBuilder: OqlBuilder[CourseJournal] = {
    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    query.where("journal.department in(:departs)", departs)
    getLong("grade.id") foreach { gradeId =>
      val grade = entityDao.get(classOf[Grade], gradeId)
      query.where("journal.beginOn <=:beginOn and (journal.endOn is null or journal.endOn >= :beginOn)", grade.beginOn)
    }
    getBoolean("creditHourStatus") foreach { status =>
      if (status) {
        query.where(s"journal.creditHours = (select sum(h.creditHours) from journal.hours h)")
      } else {
        query.where(s"journal.creditHours <> (select sum(h.creditHours) from journal.hours h) or journal.creditHours>0 and size(journal.hours) = 0")
      }
    }
    getBoolean("tagStatus") foreach { status =>
      if status then query.where(s"size(journal.tags)>0")
      else query.where(s"size(journal.tags)=0")
    }
    get("tagName") foreach { tagName =>
      if (Strings.isNotBlank(tagName)) {
        query.where(s"exists(from journal.tags as t where t.name like :tagName)", s"%$tagName%")
      }
    }
    query
  }

  def init(): View = {
    given project: Project = getProject

    val grade = entityDao.get(classOf[Grade], getLong("grade.id").get)
    val query = OqlBuilder.from(classOf[Course], "c")
    query.where("c.project=:project and c.endOn is null", project)
    query.where("not exists(from c.journals j where j.beginOn=:beginOn)", grade.beginOn)
    val courses = entityDao.search(query)
    courses.foreach { c =>
      val j = c.getJournal(grade)
      if (!j.persisted) {
        c.journals.addOne(j)
        var i = 0
        val journals = c.journals.sortBy(_.beginOn)
        while (i < journals.length - 1) { //最后一个不处理
          val j = journals(i)
          val jNext = journals(i + 1)
          j.endOn = Some(jNext.beginOn.minusMonths(1))
          i += 1
        }
        entityDao.saveOrUpdate(journals)
      }
    }
    val journals = courses.map(c => c.getJournal(grade))
    entityDao.saveOrUpdate(journals)
    redirect("search", "操作成功")
  }

  @response
  def downloadTemplate(): Any = {
    given project: Project = getProject

    val school = project.school
    val departs = getDeparts
    val natures = codeService.get(classOf[TeachingNature]).sortBy(_.code)
    val tags = codeService.get(classOf[CourseTag]).sortBy(_.code)
    val examModes = codeService.get(classOf[ExamMode]).map(x => x.code + " " + x.name)

    val schema = new ExcelSchema()
    val sheet = schema.createScheet("数据模板")
    sheet.title("课程标记信息")
    sheet.remark("特别说明：课程标记中，可在相应的列填Y、是、y任意一种,没有可不填")
    sheet.add("课程代码", "course.code").length(10).required().remark("≤10位")
    sheet.add("课程名称", "name")
    sheet.add("课程学分", "defaultCredits")
    //    sheet.add("课程学时", "course.creditHours")
    //    natures foreach { n =>
    //      sheet.add(n.name, s"hour${n.id}").integer()
    //    }
    //    sheet.add("考核方式", "journal.examMode.code").ref(examModes).required()
    tags foreach { tag =>
      sheet.add(tag.name, s"tag${tag.id}").remark("")
    }
    val os = new ByteArrayOutputStream()
    schema.generate(os)
    Stream(new ByteArrayInputStream(os.toByteArray), MediaTypes.ApplicationXlsx.toString, "课程标记信息.xlsx")
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new CourseJournalPropertyExtractor()
  }

  protected override def configImport(setting: ImportSetting): Unit = {
    val project = getProject
    val natures = codeService.get(classOf[TeachingNature]).sortBy(_.code)
    val tags = codeService.get(classOf[CourseTag]).sortBy(_.code)
    val grade = entityDao.search(OqlBuilder.from(classOf[Grade], "g").where("g.beginOn>:now and g.project=:project", LocalDate.now, project)).head
    setting.listeners = List(ForeignerListener(entityDao), new CourseJournalImportListener(entityDao, grade, natures, tags))
  }

  override def simpleEntityName: String = "journal"
}
