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
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.code.edu.model.{TeachingMethod, TeachingSection}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{Lesson, Syllabus, TeachingPlan, TeachingPlanSection}
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.TeachingPlanHelper
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.support.TeacherSupport

import java.time.{Instant, LocalTime}
import java.util.Locale

/** 修订授课计划表
 */
class ReviseAction extends TeacherSupport, EntityAction[Syllabus] {
  var clazzProvider: ClazzProvider = _
  var businessLogger: WebBusinessLogger = _
  var courseTaskService: CourseTaskService = _

  protected override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val semester = getSemester
    put("semester", semester)

    val clazzes = clazzProvider.getClazzes(semester, teacher, project)
    val scheduled = clazzes.filter(_.schedule.activities.nonEmpty)
    if (scheduled.nonEmpty) {
      put("plans", entityDao.findBy(classOf[TeachingPlan], "clazz", scheduled).map(x => (x.clazz, x)).toMap)
    }
    val syllabusCourses = entityDao.findBy(classOf[Syllabus], "course", clazzes.map(_.course)).map(_.course)
    put("syllabusCourses", syllabusCourses)
    put("clazzes", scheduled)
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

    val syllabus = entityDao.findBy(classOf[Syllabus], "course", clazz.course).headOption
    put("syllabus", syllabus)
    val schedules = LessonSchedule.convert(clazz.schedule.activities, beginAt, endAt)
    (plan.lessons.size + 1 to schedules.size) foreach { i =>
      val lesson = new Lesson()
      lesson.plan = plan
      lesson.idx = i
      plan.lessons.addOne(lesson)
    }
    val hours = plan.sections.map(x => (x.name, x.creditHours)).toMap
    put("hours", hours)
    put("schedules", schedules)
    forward()
  }

  def save(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))

    given project: Project = clazz.project

    val me = getTeacher
    val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clazz)
    val plan = plans.headOption.getOrElse(new TeachingPlan)
    if (!plan.persisted) {
      plan.clazz = clazz
      plan.semester = clazz.semester
      plan.docLocale = Locale.SIMPLIFIED_CHINESE
    }
    (1 to 20) foreach { i =>
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
      lesson.learningHours = getInt(s"lesson${i}.learningHours", 0)
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
    //保存课时
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
    plan.office = courseTaskService.getOffice(clazz.course, clazz.teachDepart, clazz.semester)
    plan.writer = entityDao.findBy(classOf[User], "school" -> plan.clazz.project.school, "code" -> me.code).headOption
    plan.office foreach { o =>
      plan.reviewer = courseTaskService.getOfficeDirector(clazz.course, clazz.teachDepart, clazz.semester)
    }
    entityDao.saveOrUpdate(plan)

    val submit = getBoolean("submit", false)
    val isDirector = courseTaskService.isDirector(clazz.course, me)
    //课程负责人
    if (isDirector) {
      val cq = OqlBuilder.from(classOf[Clazz], "clz")
      cq.where("clz.project=:project", clazz.project)
      cq.where("clz.course=:course", clazz.course)
      cq.where("clz.semester=:semester", clazz.semester)
      cq.where("clz.id!=:clazzId", clazz.id)
      val clzs = entityDao.search(cq)
      val plans = entityDao.findBy(classOf[TeachingPlan], "clazz", clzs).map(x => (x.clazz, x)).toMap

      clzs foreach { clz =>
        val p = plans.getOrElse(clz, new TeachingPlan(clz))
        if (p.writer.isEmpty || p.writer.map(_.code).contains(me.code)) {
          plan.copyTo(p)
          val editables = Set(AuditStatus.Draft, AuditStatus.Submited, AuditStatus.Rejected, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart)
          if (submit && editables.contains(p.status)) {
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
    forward(s"/org/openurp/edu/course/lesson/${plan.clazz.project.school.id}/${plan.clazz.project.id}/report")
  }
}
