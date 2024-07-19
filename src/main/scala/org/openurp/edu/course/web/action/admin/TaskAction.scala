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
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.excel.schema.ExcelSchema
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.doc.transfer.importer.ImportSetting
import org.beangle.doc.transfer.importer.listener.ForeignerListener
import org.beangle.web.action.annotation.response
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.{ExportSupport, ImportSupport, RestfulAction}
import org.openurp.base.edu.model.{CourseDirector, TeachingOffice}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{AuditStatus, Department, Project, Semester}
import org.openurp.code.edu.model.{CourseCategory, CourseNature}
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseTask, Syllabus, TeachingPlan}
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.{CourseTaskImportListener, CourseTaskPropertyExtractor}
import org.openurp.starter.web.support.ProjectSupport

import java.io.{ByteArrayInputStream, ByteArrayOutputStream}
import java.time.LocalDate

/** 课程任务
 */
class TaskAction extends RestfulAction[CourseTask], ProjectSupport, ImportSupport[CourseTask], ExportSupport[CourseTask] {

  var courseTaskService: CourseTaskService = _

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departments", departs)
    put("project", project)
    put("semester", getSemester)
    put("offices", getOffices(project, departs))
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[CourseTask] = {
    val query = super.getQueryBuilder
    query.where("courseTask.course.project=:project", getProject)
    queryByDepart(query, "courseTask.department")
    get("teachers").foreach {
      case "2" => query.where("size(courseTask.teachers) > 1")
      case "1" => query.where("size(courseTask.teachers) = 1")
      case "0" => query.where("size(courseTask.teachers) = 0")
      case _ =>
    }
    get("syllabus_status").foreach {
      case "1" => query.where(s"exists(from ${classOf[Syllabus].getName} s where s.course=courseTask.course" +
        s" and s.semester=courseTask.semester and s.status in (:statuses))",
        List(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.PassedByDepart, AuditStatus.Passed))
      case "0" =>
        query.where("courseTask.syllabusRequired=true")
        query.where(s"not exists(from ${classOf[Syllabus].getName} s where s.course=courseTask.course" +
          s" and s.semester=courseTask.semester and s.status in (:statuses))",
          List(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.PassedByDepart, AuditStatus.Passed))
      case _ =>
    }
    get("plan_status").foreach {
      case "1" => query.where(s"exists(from ${classOf[TeachingPlan].getName} s where s.clazz.course=courseTask.course" +
        s" and s.semester=courseTask.semester and s.status in (:statuses))",
        List(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.PassedByDepart, AuditStatus.Passed))
      case "0" =>
        query.where("courseTask.syllabusRequired=true")
        query.where(s"not exists(from ${classOf[TeachingPlan].getName} s where s.clazz.course=courseTask.course" +
          s" and s.semester=courseTask.semester and s.status in (:statuses))",
          List(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.PassedByDepart, AuditStatus.Passed))
      case _ =>
    }
    get("schedule_status").foreach {
      case "1" => query.where(s"exists(from ${classOf[Clazz].getName} s where s.course=courseTask.course" +
        s" and s.semester=courseTask.semester and size(s.schedule.activities)>0)")
      case "0" =>
        query.where(s"not exists(from ${classOf[Clazz].getName} s where s.course=courseTask.course" +
          s" and s.semester=courseTask.semester and size(s.schedule.activities)>0)")
      case _ =>
    }
    getBoolean("assigned").foreach {
      case true => query.where("courseTask.director is not null")
      case false => query.where("courseTask.director is null")
    }
    val teacherName = get("teacherName").orNull
    if (Strings.isNotBlank(teacherName)) {
      query.where("exists(from courseTask.teachers t where t.name like :name)", s"%$teacherName%")
    }
    query
  }

  override protected def editSetting(task: CourseTask): Unit = {
    given project: Project = getProject

    put("project", project)

    val departs = getDeparts
    put("departments", departs)
    put("offices", entityDao.findBy(classOf[TeachingOffice], "project" -> project, "department" -> task.department))
    //课程负责人和上课老师作为该学期负责人的候选人
    val director = entityDao.findBy(classOf[CourseDirector], "course", task.course).headOption
    put("director", director)
    val directors = Collections.newBuffer[Teacher]
    directors ++= task.teachers
    for (d <- director; t <- d.director) {
      if !directors.contains(t) then directors += t
    }

    put("directors", directors)
    super.editSetting(task)
  }

  def autoCreate(): View = {
    given project: Project = getProject

    val semester = entityDao.get(classOf[Semester], getIntId("courseTask.semester"))
    courseTaskService.statTask(project, semester)
    redirect("search", "初始化成功")
  }

  def autoAssign(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    tasks foreach { t =>
      if (t.director.isEmpty) {
        if (t.teachers.size == 1) {
          t.director = t.teachers.headOption
        } else {
          entityDao.findBy(classOf[CourseDirector], "course", t.course).foreach { d =>
            d.director foreach { dd =>
              if t.teachers.contains(dd) then t.director = Some(dd)
            }
            d.office foreach { o =>
              t.office = Some(o)
            }
          }
        }
      }
      if (t.office.isEmpty) {
        entityDao.findBy(classOf[CourseDirector], "course", t.course).foreach { d =>
          d.office foreach { o => t.office = Some(o) }
        }
      }
    }
    entityDao.saveOrUpdate(tasks)
    redirect("search", "自动指派成功")
  }

  def batchEdit(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    val task = tasks.head
    put("offices", entityDao.findBy(classOf[TeachingOffice], "project" -> task.course.project, "department" -> task.department))
    put("courseTasks", tasks)
    put("project", getProject)
    forward()
  }

  def batchSave(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    getLong("teacher.id") foreach { id =>
      val t = entityDao.get(classOf[Teacher], id)
      tasks foreach (_.director = Some(t))
    }
    getLong("office.id") foreach { officeId =>
      val office = entityDao.get(classOf[TeachingOffice], officeId)
      tasks foreach (_.office = Some(office))
    }
    getBoolean("syllabusRequired") foreach { required =>
      tasks foreach (_.syllabusRequired = required)
    }
    entityDao.saveOrUpdate(tasks)
    redirect("search", "批量成功")
  }

  private def getOffices(project: Project, departs: Seq[Department]): Seq[TeachingOffice] = {
    val query = OqlBuilder.from(classOf[TeachingOffice], "o")
    query.where("o.project=:project", project)
    query.where("o.department in(:departs)", departs)
    query.orderBy("o.name")
    entityDao.search(query)
  }

  @response
  def downloadTemplate(): Any = {
    given project: Project = getProject

    val school = project.school
    val departs = getDeparts
    val departNames = entityDao.search(OqlBuilder.from(classOf[Department], "bt").where("bt.school=:school", school)
      .orderBy("bt.name")).map(x => x.code + " " + x.name)

    val offices = entityDao.search(OqlBuilder.from(classOf[TeachingOffice], "t").where("t.project=:project", project)
      .where("t.endOn is null or t.endOn > :today", LocalDate.now)
      .where("t.department in(:departs)", departs)
      .orderBy("t.code")).map(x => x.code + " " + x.name)

    val natures = codeService.get(classOf[CourseNature]).map(x => x.code + " " + x.name)
    val categories = codeService.get(classOf[CourseCategory]).map(x => x.code + " " + x.name)

    val schema = new ExcelSchema()
    val sheet = schema.createScheet("数据模板")
    sheet.title("课程负责人信息模板")
    sheet.remark("特别说明：\n1、不可改变本表格的行列结构以及批注，否则将会导入失败！\n2、必须按照规格说明的格式填写。\n3、可以多次导入，重复的信息会被新数据更新覆盖。\n4、保存的excel文件名称可以自定。")
    sheet.add("课程代码", "course.code").length(10).required().remark("≤10位")
    sheet.add("开课院系", "department.code").ref(departNames).required()
    sheet.add("教研室", "courseTask.office.code").ref(offices).required()
    sheet.add("课程负责人工号或姓名", "teacher.code").required()

    val os = new ByteArrayOutputStream()
    schema.generate(os)
    Stream(new ByteArrayInputStream(os.toByteArray), MediaTypes.ApplicationXlsx.toString, "课程负责人.xlsx")
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new CourseTaskPropertyExtractor()
  }

  protected override def configImport(setting: ImportSetting): Unit = {
    val semester = entityDao.get(classOf[Semester], getIntId("courseTask.semester"))
    setting.listeners = List(ForeignerListener(entityDao), new CourseTaskImportListener(entityDao, semester, getProject))
  }
}
