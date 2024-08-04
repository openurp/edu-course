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
import org.beangle.data.model.annotation.code
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Project, User}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{ClazzPlan, ClazzProgram, LessonDesign, LessonDesignText, SyllabusObjective}
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.schedule.service.ScheduleDigestor
import org.openurp.starter.web.support.TeacherSupport

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

  def saveDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val idx = getInt("design.idx", 1)
    val design = program.get(idx).getOrElse(new LessonDesign(program, idx))
    design.subject = get("design.subject", "")
    populateText(design, "design.target")
    populateText(design, "design.emphasis")
    populateText(design, "design.difficulties")
    populateText(design, "design.resources")
    populateText(design, "design.values")
    entityDao.saveOrUpdate(design)

    redirect("designInfo", s"design.id=${design.id}", "info.save.success")
  }

  def designInfo(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    forward()
  }

  private def populateText(design: LessonDesign, name: String): Unit = {
    val contents = cleanText(get(name, ""))
    design.getText(name) match {
      case None =>
        if Strings.isNotBlank(contents) then
          val o = new LessonDesignText(design, name, contents)
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
