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

import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.ems.app.EmsApi
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.beangle.webmvc.view.{Stream, View}
import org.openurp.base.model.Project
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{ClazzPlan, ClazzProgram, LessonDesign}
import org.openurp.edu.course.web.helper.{ClazzPlanHelper, ClazzProgramHelper}
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.helper.ProjectProfile
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI

class DepartAction extends RestfulAction[ClazzProgram], ProjectSupport, ExportSupport[ClazzProgram] {

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    forward()
  }

  override def getQueryBuilder: OqlBuilder[ClazzProgram] = {
    val query = super.getQueryBuilder
    val lessonOn = getDate("lessonOn")
    val unit = getShort("unit")
    if (lessonOn.nonEmpty || unit.nonEmpty) {
      if (lessonOn.nonEmpty && unit.nonEmpty) {
        query.where("exists(from clazzProgram.designs as d where d.lessonOn = :lessonOn" +
          " and :unit between pair_1(d.units) and pair_2(d.units))", lessonOn.get, unit.get)
      } else if (lessonOn.nonEmpty) {
        query.where("exists(from clazzProgram.designs as d where d.lessonOn = :lessonOn)", lessonOn.get)
      } else {
        query.where("exists(from clazzProgram.designs as d where :unit between pair_1(d.units) and pair_2(d.units))", unit.get)
      }
    }
    query
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
    ProjectProfile.set(project)
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
    ProjectProfile.set(project)
    forward("/org/openurp/edu/course/web/components/program/designReport")
  }

  def designPdf(): View = {
    val id = getLongId("design")
    val clazzId = getLongId("clazz")
    val design = entityDao.get(classOf[LessonDesign], id)
    val url = EmsApi.url(s"/program/depart/designReport?design.id=${id}&clazz.id=${clazzId}")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    val clazz = design.program.clazz
    Stream(pdf, clazz.crn + "_" + clazz.course.name + s" 授课教案 第${design.idx}次课.pdf").cleanup(() => pdf.delete())
  }

  def fix(): View = {
    val programs = entityDao.getAll(classOf[ClazzProgram])
    programs foreach { p =>
      ClazzProgramHelper.updateStatInfo(p)
      entityDao.saveOrUpdate(p)
    }
    forward()
  }

}
