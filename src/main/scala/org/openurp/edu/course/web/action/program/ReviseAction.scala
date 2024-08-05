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

package org.openurp.edu.course.web.action.program

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
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
import org.openurp.base.model.{Project, User}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.*
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.ClazzPlanHelper
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.support.TeacherSupport

import java.io.File
import java.net.URI
import java.time.Instant

class ReviseAction extends TeacherSupport, EntityAction[ClazzProgram] {
  var clazzProvider: ClazzProvider = _
  var businessLogger: WebBusinessLogger = _
  var courseTaskService: CourseTaskService = _

  protected override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val semester = getSemester
    put("semester", semester)

    val clazzes = Collections.newSet[Clazz]
    clazzes.addAll(clazzProvider.getClazzes(semester, teacher, project))

    val scheduled = clazzes.filter(_.schedule.activities.nonEmpty)
    if (scheduled.nonEmpty) {
      put("plans", entityDao.findBy(classOf[ClazzPlan], "clazz", scheduled).map(x => (x.clazz, x)).toMap)
      put("programs", entityDao.findBy(classOf[ClazzProgram], "clazz", scheduled).map(x => (x.clazz, x)).toMap)
    } else {
      put("plans", Map.empty)
      put("programs", Map.empty)
    }
    put("clazzes", scheduled)
    forward()
  }

  def edit(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))
    val plan = entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).head
    put("clazz", clazz)
    put("plan", plan)
    put("schedule_time", ScheduleDigestor.digest(clazz, ":day :units :weeks"))
    put("schedule_space", ScheduleDigestor.digest(clazz, ":room"))
    val programs = entityDao.findBy(classOf[ClazzProgram], "clazz", clazz)
    val program = programs.headOption.getOrElse(new ClazzProgram(clazz))
    if (!program.persisted) {
      program.writer = entityDao.findBy(classOf[User], "school" -> plan.clazz.project.school, "code" -> Securities.user).head
      program.updatedAt = Instant.now
      entityDao.saveOrUpdate(program)
    }
    put("program", program)
    val project = program.clazz.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward()
  }

  def save(): View = {
    forward()
  }

  def editDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val design =
      getLong("design.id") match
        case Some(id) => entityDao.get(classOf[LessonDesign], id)
        case None => new LessonDesign(program, getInt("idx", 1))

    put("design", design)
    put("program", program)
    forward()
  }

  def uploadImage(): View = {
    forward()
  }

  def saveDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val idx = getInt("design.idx", 1)
    val design = program.get(idx).getOrElse(new LessonDesign(program, idx))
    design.subject = get("design.subject", "")
    design.homework = get("design.homework")
    val clazz = program.clazz
    val schedules = LessonSchedule.convert(clazz)
    design.creditHours = schedules(design.idx - 1).hours
    populateText(design, "design.target")
    populateText(design, "design.emphasis")
    populateText(design, "design.difficulties")
    populateText(design, "design.resources")
    populateText(design, "design.values")
    (1 to 10) foreach { i =>
      val title = get(s"sections[${i}].title", "")
      val duration = getInt(s"sections[${i}].duration", 0)
      val summary = get(s"sections[${i}].summary", " ")
      val details = get(s"sections[${i}].details", " ")
      if Strings.isNotBlank(title) then
        val section = design.getSection(i).getOrElse(new LessonDesignSection(design, i, title, duration, summary, details))
        section.title = title
        section.duration = duration
        section.summary = summary
        section.details = details
        design.sections += section
        if (!section.persisted) {
          design.sections += section
        }
    }
    entityDao.saveOrUpdate(design)

    redirect("designInfo", s"design.id=${design.id}", "info.save.success")
  }

  def designInfo(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    forward()
  }

  def designReport(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    val clazz = design.program.clazz
    put("plan", entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).headOption)
    val syllabus = ClazzPlanHelper(entityDao).findSyllabus(clazz)
    put("clazz", clazz)
    put("syllabus", syllabus)
    val project = design.program.clazz.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward("/org/openurp/edu/course/web/components/program/designReport")
  }

  def designPdf(): View = {
    val id = getLongId("design")
    val design = entityDao.get(classOf[LessonDesign], id)
    val url = Ems.base + ActionContext.current.request.getContextPath + s"/program/revise/designReport?design.id=${id}&URP_SID=" + Securities.session.map(_.id).getOrElse("")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    val clazz = design.program.clazz
    Stream(pdf, clazz.crn + "_" + clazz.course.name + s" 授课教案 第${design.idx}次课.pdf").cleanup(() => pdf.delete())
  }

  private def populateText(design: LessonDesign, name: String): Unit = {
    val contents = cleanText(get(name, ""))
    val textName = name.substring("design.".length)
    design.getText(textName) match {
      case None =>
        if Strings.isNotBlank(contents) then
          val o = new LessonDesignText(design, textName, contents)
          design.texts += o
      case Some(o) =>
        if Strings.isBlank(contents) then
          design.texts -= o
        else
          o.contents = contents
    }
  }

  /**
   * 清理文本内容，移除换行符和回车符。
   *
   * 该函数的目的是为了处理文本，确保文本中不包含任何的回车符(\r)或换行符(\n)。
   * 这对于一些需要统一文本格式的场景非常有用，比如处理从不同来源获取的文本数据。
   *
   * @param contents 待清理的文本字符串。
   * @return 清理后的文本字符串，不包含任何回车符或换行符。
   */
  private def cleanText(contents: String): String = {
    // 移除文本中的回车符
    var c = Strings.replace(contents, "\r", "")
    // 移除文本中的换行符
    c = Strings.replace(c, "\n", "")
    c
  }

  def report(): View = {
    forward()
  }

  def pdf(): View = {
    val id = getLongId("plan")
    val plan = entityDao.get(classOf[ClazzPlan], id)
    forward()
  }
}
