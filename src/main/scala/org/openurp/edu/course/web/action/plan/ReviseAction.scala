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

package org.openurp.edu.course.web.action.plan

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.ems.app.Ems
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.code.edu.model.{TeachingMethod, TeachingSection}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.*
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.TeachingPlanHelper
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.support.TeacherSupport

import java.io.File
import java.net.URI
import java.time.{Instant, LocalTime}

/** 修订授课计划表
 */
class ReviseAction extends TeacherSupport, EntityAction[Syllabus] {
  var clazzProvider: ClazzProvider = _
  var businessLogger: WebBusinessLogger = _
  var courseTaskService: CourseTaskService = _

  /** 查询修订任务对应的教学任务
   *
   * @param task
   * @param teacher
   * @return
   */
  private def getCourseTaskClazzes(task: CourseTask): Iterable[Clazz] = {
    val clazzes = Collections.newSet[Clazz]
    val q = OqlBuilder.from(classOf[CourseTask], "c")
    q.where("c.course.project=:project", task.course.project)
    q.where("c.semester=:semester", task.semester)
    q.where("c.course=:course", task.course)
    q.where("c.id != :taskId", task.id)
    val otherCourseTasks = entityDao.search(q)
    val query = OqlBuilder.from(classOf[Clazz], "clazz")
    query.where("clazz.project=:project and clazz.semester=:semester", task.course.project, task.semester)
    query.where("clazz.course =:course", task.course)
    val courseClazzes = entityDao.search(query)
    if (otherCourseTasks.isEmpty) { // 只有本人负责该课程
      clazzes.addAll(courseClazzes)
    } else {
      courseClazzes foreach { clazz =>
        val clazzTeachers = clazz.teachers.toSet
        if (clazzTeachers.subsetOf(task.teachers)) {
          clazzes.addOne(clazz)
        }
      }
    }
    clazzes
  }

  protected override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val semester = getSemester
    put("semester", semester)

    val clazzes = Collections.newSet[Clazz]
    clazzes.addAll(clazzProvider.getClazzes(semester, teacher, project))

    val q = OqlBuilder.from(classOf[CourseTask], "c")
    q.where("c.course.project=:project", project)
    q.where("c.semester=:semester", semester)
    q.where("c.director=:me", teacher)
    val tasks = entityDao.search(q)

    if (tasks.nonEmpty) {
      tasks foreach { task => clazzes.addAll(getCourseTaskClazzes(task)) }
    }

    val scheduled = clazzes.filter(_.schedule.activities.nonEmpty)
    if (scheduled.nonEmpty) {
      put("plans", entityDao.findBy(classOf[TeachingPlan], "clazz", scheduled).map(x => (x.clazz, x)).toMap)
    }
    val syllabusCourses = entityDao.findBy(classOf[Syllabus], "course", clazzes.map(_.course)).map(_.course)
    put("syllabusCourses", syllabusCourses)
    put("clazzes", scheduled)
    put("editables", Set(AuditStatus.Draft, AuditStatus.Submited, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart))

    forward()
  }

  def clazz(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))
    val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clazz)
    if (plans.isEmpty) {
      redirect("edit", s"&clazz.id=${clazz.id}", "")
    } else {
      put("plan", plans.head)
      forward()
    }
  }

  def edit(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))

    given project: Project = clazz.project

    val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clazz)
    val plan = plans.headOption.getOrElse(new TeachingPlan)
    put("plan", plan)
    put("clazz", clazz)
    put("schedule_time", ScheduleDigestor.digest(clazz, ":day :units :weeks"))
    put("schedule_space", ScheduleDigestor.digest(clazz, ":room"))
    put("teachingForms", getCodes(classOf[TeachingMethod]))

    val sections = getCodes(classOf[TeachingSection]).map(_.name)
    val sectionNames = Collections.newBuffer[String]
    sectionNames ++= plan.sections.map(_.name)
    sections foreach { s => if !sectionNames.contains(s) then sectionNames.addOne(s) }
    put("sectionNames", sectionNames.slice(0, 6))

    val semester = clazz.semester
    val beginAt = semester.beginOn.atTime(LocalTime.MIN)
    val endAt = semester.endOn.atTime(LocalTime.MAX)

    put("syllabus", new TeachingPlanHelper(entityDao).findSyllabus(clazz))
    val schedules = LessonSchedule.convert(clazz)

    val scheduleHours = schedules.map(_.hours).sum
    put("scheduleHours", scheduleHours)
    (plan.lessons.size + 1 to schedules.size) foreach { i =>
      val lesson = new Lesson()
      lesson.plan = plan
      lesson.idx = i
      plan.lessons.addOne(lesson)
    }
    val hours = plan.sections.map(x => (x.name, x.creditHours)).toMap
    put("hours", hours)
    put("schedules", schedules)
    plan.office = courseTaskService.getOffice(clazz.semester, clazz.course, clazz.teachDepart)
    plan.office foreach { o =>
      plan.reviewer = courseTaskService.getOfficeDirector(clazz.semester, clazz.course, clazz.teachDepart)
    }
    forward()
  }

  def save(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))

    given project: Project = clazz.project

    val me = getTeacher
    val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clazz)
    val plan = plans.headOption.getOrElse(new TeachingPlan)
    if (!plan.persisted) {
      plan.clazz = clazz
      plan.semester = clazz.semester
    }
    (1 to 60) foreach { i =>
      val lesson = plan.lessons.find(_.idx == i).getOrElse(new Lesson)
      lesson.idx = i
      lesson.contents = get(s"lesson${i}.contents", "")
      lesson.learning = get(s"lesson${i}.learning")
      if (lesson.learning.nonEmpty) {
        if (Strings.isBlank(lesson.learning.get)) {
          lesson.learning = None
          lesson.learningHours = 0
        }
      }
      lesson.homework = get(s"lesson${i}.homework")
      lesson.learningHours = getFloat(s"lesson${i}.learningHours").getOrElse(0f)
      lesson.forms = get(s"lesson${i}.forms")

      if (lesson.contents.nonEmpty) {
        if (lesson.plan == null) {
          lesson.plan = plan
          plan.lessons.addOne(lesson)
        }
      } else {
        if null != lesson.plan then plan.lessons.subtractOne(lesson)
      }
    }
    //保存学时
    val hours = plan.sections.map(x => (x.name, x)).toMap
    val sectionNames = Collections.newSet[String]
    (0 until 8) foreach { i =>
      get(s"section${i}.name") foreach { name => sectionNames.addOne(name) }
    }
    plan.reserveSections(sectionNames)
    (0 until 8) foreach { i =>
      val creditHours = getInt(s"section${i}.creditHours", 0)
      get(s"section${i}.name") foreach { name =>
        if (creditHours > 0) {
          plan.addSection(name, creditHours)
        } else {
          hours.get(name) match
            case None =>
            case Some(s) => plan.sections.subtractOne(s)
        }
      }
    }
    plan.updatedAt = Instant.now
    plan.writer = entityDao.findBy(classOf[User], "school" -> plan.clazz.project.school, "code" -> me.code).head
    plan.office = courseTaskService.getOffice(clazz.semester, clazz.course, clazz.teachDepart)
    plan.office foreach { o =>
      plan.reviewer = courseTaskService.getOfficeDirector(clazz.semester, clazz.course, clazz.teachDepart)
    }
    plan.examHours = syllabus.examCreditHours
    plan.lessonHours = getInt("lessonHours", 0)

    entityDao.saveOrUpdate(plan)

    val submit = getBoolean("submit", false)

    val q = OqlBuilder.from(classOf[CourseTask], "c")
    q.where("c.semester=:semester", clazz.semester)
    q.where("c.course=:course and c.director=:me", clazz.course, me)
    val tasks = entityDao.search(q)
    val isDirector = tasks.nonEmpty
    //课程负责人
    if (isDirector) {
      val clzs = getCourseTaskClazzes(tasks.head).filter(_.id != clazz.id)
      val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clzs).map(x => (x.clazz, x)).toMap

      val writerCodes = clzs.flatMap(_.teachers.map(_.code)).toSet
      clzs foreach { clz =>
        val p = plans.getOrElse(clz, new TeachingPlan(clz))
        val clazzTeachers = clazz.teachers.toSet
        if (null == p.writer || p.writer.code == me.code || !writerCodes.contains(p.writer.code)) {
          val editables = Set(AuditStatus.Draft, AuditStatus.Submited, AuditStatus.Rejected, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart)
          if (submit && editables.contains(p.status)) {
            plan.copyTo(p)
            p.status = AuditStatus.Submited
          }
          entityDao.saveOrUpdate(p)
        }
      }
    }

    getBoolean("submit") foreach { s =>
      plan.status = AuditStatus.Submited
      entityDao.saveOrUpdate(plan)
      businessLogger.info(s"提交课程授课计划:${clazz.course.name}", plan.id, Map("course" -> clazz.course.id.toString))
    }

    redirect("report", "plan.id=" + plan.id, "info.save.success")
  }

  def report(): View = {
    val plan = entityDao.get(classOf[TeachingPlan], getLongId("plan"))
    new TeachingPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    val project = plan.clazz.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward(s"/org/openurp/edu/course/web/components/plan/report_zh_CN")
  }

  def pdf(): View = {
    val id = getLongId("plan")
    val plan = entityDao.get(classOf[TeachingPlan], id)
    val url = Ems.base + ActionContext.current.request.getContextPath + s"/plan/revise/report?id=${id}&URP_SID=" + Securities.session.map(_.id).getOrElse("")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    Stream(pdf, plan.clazz.crn + "_" + plan.clazz.course.name + " 授课计划.pdf").cleanup(() => pdf.delete())
  }
}
