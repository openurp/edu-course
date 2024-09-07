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

import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.Project
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{ClazzPlan, ClazzProgram, LessonDesign}
import org.openurp.edu.course.web.helper.{ClazzPlanHelper, EmsUrl}
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI

class DepartAction extends RestfulAction[ClazzProgram], ProjectSupport {

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    forward()
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val clazz = program.clazz
    val plan = entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).head
    put("clazz", clazz)
    put("plan", plan)
    put("schedules", LessonSchedule.convert(clazz))
    put("schedule", ScheduleDigestor.digest(clazz, ":day :units(:time) :weeks :room"))
    put("program", program)
    val project = program.clazz.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward()
  }

  def designReport(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    val clazz = getLong("clazz.id") match {
      case None => design.program.clazz
      case Some(clazzId) => entityDao.get(classOf[Clazz], clazzId)
    }

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
    val clazzId = getLongId("clazz")
    val design = entityDao.get(classOf[LessonDesign], id)
    val url = EmsUrl.url(s"/program/depart/designReport?design.id=${id}&clazz.id=${clazzId}")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    val clazz = design.program.clazz
    Stream(pdf, clazz.crn + "_" + clazz.course.name + s" 授课教案 第${design.idx}次课.pdf").cleanup(() => pdf.delete())
  }


}
