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

package org.openurp.edu.course.web.action.syllabus

import org.beangle.commons.bean.orderings.PropertyOrdering
import org.beangle.commons.collection.Collections
import org.beangle.commons.concurrent.Workers
import org.beangle.commons.file.zip.Zipper
import org.beangle.commons.io.Files
import org.beangle.commons.lang.SystemInfo
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.ems.app.Ems
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.{AuditStatus, CalendarStage, Project, Semester}
import org.openurp.code.edu.model.*
import org.openurp.edu.course.model.{CourseTask, Syllabus}
import org.openurp.edu.course.web.helper.{StatItem, SyllabusHelper, SyllabusPropertyExtractor}
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI
import java.util.Locale

/** 学院查询教学大纲
 */
class DepartAction extends RestfulAction[Syllabus], ProjectSupport, ExportSupport[Syllabus] {
  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    put("statuses", List(AuditStatus.Draft, AuditStatus.Submited,
      AuditStatus.RejectedByDirector, AuditStatus.PassedByDirector,
      AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart,
      AuditStatus.Rejected, AuditStatus.Passed))
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[Syllabus] = {
    given project: Project = getProject

    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))

    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    queryByDepart(query, "syllabus.department")
  }

  def audit(): View = {
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus"))
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.Passed else AuditStatus.Rejected
      syllabuses foreach { s => s.status = status }
    }
    entityDao.saveOrUpdate(syllabuses)
    redirect("search", "审核成功")
  }

  override protected def removeAndRedirect(syllabuses: Seq[Syllabus]): View = {
    val removables = Seq(AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.Draft)
    super.removeAndRedirect(syllabuses.filter(x => removables.contains(x.status)))
  }

  override protected def editSetting(syllabus: Syllabus): Unit = {
    given project: Project = getProject

    put("project", project)
    put("departments", List(syllabus.department))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("courseNatures", getCodes(classOf[CourseNature]))
    put("examModes", getCodes(classOf[ExamMode]))
    put("gradingModes", getCodes(classOf[GradingMode]))
    put("courseModules", getCodes(classOf[CourseModule]))
    put("courseRanks", getCodes(classOf[CourseRank]))

    val s = OqlBuilder.from(classOf[CalendarStage], "s")
    s.where("s.school=:school and s.vacation=false", project.school)
    s.orderBy("s.startWeek").cacheable()
    put("calendarStages", entityDao.search(s))
    put("locales", Map(new Locale("zh", "CN") -> "中文大纲", new Locale("en", "US") -> "English Syllabus"))
    put("offices", entityDao.findBy(classOf[TeachingOffice], "project" -> project, "department" -> syllabus.department))
    super.editSetting(syllabus)
  }

  override protected def saveAndRedirect(syllabus: Syllabus): View = {
    syllabus.beginOn = syllabus.semester.beginOn

    super.saveAndRedirect(syllabus)
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val syllabus = entityDao.get(classOf[Syllabus], id.toLong)
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    val project = syllabus.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward(s"/org/openurp/edu/course/web/components/syllabus/report_${syllabus.docLocale}")
  }

  def download(): View = {
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus"))
    val pdfDir = SystemInfo.tmpDir + "/" + s"syllabus_${Securities.user}"
    Files.travel(new File(pdfDir), f => f.delete())
    val contextPath = ActionContext.current.request.getContextPath
    new File(pdfDir).mkdirs()
    if (syllabuses.size == 1) {
      val syllabus = syllabuses.head
      val url = Ems.base + contextPath + s"/syllabus/depart/${syllabus.id}?URP_SID=" + Securities.session.map(_.id).getOrElse("")
      val fileName = Files.purify(syllabus.course.code + "_" + syllabus.course.name + "_" + syllabus.writer.name + "_课程大纲")
      val pdf = new File(pdfDir + s"/${fileName}.pdf")
      val options = new PrintOptions
      options.scale = 0.66d
      println(s"download ${url} to ${pdf.getAbsolutePath}")
      SPDConverter.getInstance().convert(URI.create(url), pdf, options)
      Stream(pdf).cleanup { () =>
        pdf.delete()
        //new File(pdfDir).delete()
      }
    } else {
      val datas = syllabuses.map(x => (x.id, Files.purify(x.course.code + "_" + x.course.name + "_" + x.writer.name + "_课程大纲")))
      Workers.work(datas, (data: (Long, String)) => {
        val url = Ems.base + contextPath + s"/syllabus/depart/${data._1}?URP_SID=" + Securities.session.map(_.id).getOrElse("")
        val pdf = new File(pdfDir + s"/${data._2}.pdf")
        val options = new PrintOptions
        options.scale = 0.66d
        println(s"download ${url} to ${pdf.getAbsolutePath}")
        SPDConverter.getInstance().convert(URI.create(url), pdf, options)
      }, Runtime.getRuntime.availableProcessors)
      val zipFile = new File(SystemInfo.tmpDir + s"/syllabus${Securities.user}.zip")
      Zipper.zip(new File(pdfDir), zipFile, "utf-8")
      Stream(zipFile).cleanup { () =>
        zipFile.delete()
        Files.travel(new File(pdfDir), f => f.delete())
      }
    }
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new SyllabusPropertyExtractor()
  }

  def stat(): View = {
    val project = getProject
    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val q = OqlBuilder.from[Array[Any]](classOf[CourseTask].getName, "t")
    q.where("t.course.project=:project and t.semester=:semester", project, semester)
    q.where("t.syllabusRequired=true")
    q.groupBy("t.department.id,t.department.code,t.department.name")
    q.select("t.department.id,t.department.code,t.department.name,count(*)")
    val taskStats = entityDao.search(q)

    val q2 = OqlBuilder.from[Array[Any]](classOf[Syllabus].getName, "s")
    q2.where("s.course.project=:project and s.semester=:semester", project, semester)
    q2.where(s"exists(from ${classOf[CourseTask].getName} ct where ct.course=s.course and ct.semester=s.semester and ct.syllabusRequired=true)")
    q2.groupBy("s.department.id")
    q2.select("s.department.id,count(distinct s.course.id)")
    q2.where("s.status != :status", AuditStatus.Draft)
    val syllabusStats = entityDao.search(q2)

    val items = Collections.newBuffer[StatItem]
    taskStats foreach { stat =>
      val entry = Collections.newMap[String, Any]
      entry.addAll(Map("id" -> stat(0).toString, "code" -> stat(1).toString, "name" -> stat(2).toString))
      val item = new StatItem
      item.entry = entry
      val s2 = syllabusStats.find(_(0) == stat(0)).map(_.apply(1).asInstanceOf[Number]).getOrElse(0)
      item.counters = Seq(stat(3).asInstanceOf[Number], s2)
      items.addOne(item)
    }

    put("project", project)
    put("semester", semester)
    put("items", items.sorted(PropertyOrdering.by("entry(code)")))
    forward()
  }
}
