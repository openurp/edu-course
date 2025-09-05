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

package org.openurp.edu.course.web.action.info

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.ems.app.EmsApi
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.{Stream, View}
import org.openurp.base.model.{AuditStatus, Department, Project, Semester}
import org.openurp.code.edu.model.*
import org.openurp.edu.course.model.{ClazzPlan, Syllabus}
import org.openurp.edu.course.web.helper.{ClazzPlanHelper, StatHelper, SyllabusHelper}
import org.openurp.starter.web.helper.ProjectProfile
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI

class SyllabusAction extends ActionSupport, EntityAction[Syllabus], ProjectSupport {

  var entityDao: EntityDao = _

  def index(): View = {
    given project: Project = getProject

    val semester = getSemester
    put("project", project)
    put("semester", semester)
    val q = OqlBuilder.from(classOf[Semester], "s")
    q.where("s.calendar=:calendar", project.calendar)
    q.where("s.year.archived=false")
    q.orderBy("s.endOn desc")
    put("semesters", entityDao.search(q))

    val dQuery = OqlBuilder.from(classOf[Syllabus].getName, "c")
    dQuery.where("c.course.project=:project", project)
    dQuery.where(":day between c.beginOn and c.endOn", semester.beginOn.plusDays(30))
    dQuery.select("c.department.id,c.department.name,count(*)")
    dQuery.groupBy("c.department.id,c.department.code,c.department.name")
    dQuery.orderBy("c.department.code,c.department.name")
    dQuery.where("c.status in(:statuses)", statuses)
    put("departStat", entityDao.search(dQuery))

    forward()
  }

  def search(): View = {
    given project: Project = getProject

    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val query = getQueryBuilder
    get("q") foreach { q =>
      query.where("syllabus.course.code like :q or syllabus.course.name like :q", s"%${q.trim}%")
    }
    query.where(":day between syllabus.beginOn and syllabus.endOn", semester.beginOn.plusDays(30))
    query.where("syllabus.course.project=:project", project)
    query.orderBy("syllabus.course.code")
    query.where("syllabus.status in(:statuses)", statuses)
    put("syllabuses", entityDao.search(query))

    getInt("syllabus.department.id") foreach { departId =>
      put("department", entityDao.get(classOf[Department], departId))
    }
    put("examModes", getCodes(classOf[ExamMode]))
    put("natures", getCodes(classOf[CourseNature]))
    put("modules", getCodes(classOf[CourseModule]))
    put("ranks", getCodes(classOf[CourseRank]))
    put("semester", semester)
    forward()
  }

  private def statuses: Seq[AuditStatus] = {
    Seq(AuditStatus.PassedByDirector, AuditStatus.PassedByDepart, AuditStatus.Passed, AuditStatus.Published)
  }

  def info(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    put("course", syllabus.course)
    put("syllabus", syllabus)
    var semester = syllabus.semester

    getInt("semester.id") foreach { semesterId =>
      semester = entityDao.get(classOf[Semester], semesterId)
    }
    put("semester", semester)
    val statHelper = new StatHelper(entityDao)
    val p = OqlBuilder.from(classOf[ClazzPlan], "p")
    p.where("p.semester=:semester", semester)
    p.where("p.clazz.course=:course", syllabus.course)
    p.where("p.status in(:statuses)", statuses)
    put("plans", entityDao.search(p))
    forward()
  }

  def syllabus(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    val project = syllabus.course.project
    ProjectProfile.set(project)
    val semester = getInt("semester.id") match
      case Some(sid) => entityDao.get(classOf[Semester], sid)
      case None => syllabus.semester
    put("semester", semester)
    forward(s"/org/openurp/edu/course/web/components/syllabus/report_${syllabus.docLocale}")
  }

  def plan(): View = {
    val plan = entityDao.get(classOf[ClazzPlan], getLongId("plan"))
    new ClazzPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    val project = plan.clazz.course.project
    ProjectProfile.set(project)
    forward(s"/org/openurp/edu/course/web/components/plan/report_zh_CN")
  }

  def syllabusPdf(): View = {
    val id = getLongId("syllabus")
    val syllabus = entityDao.get(classOf[Syllabus], id)
    val semesterId = get("semester.id", "")
    val semesterParam = if semesterId.nonEmpty then s"&semester.id=${semesterId}" else ""
    val url = EmsApi.url(s"/info/syllabus/syllabus?syllabus.id=${id}$semesterParam")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    options.scale = 0.66d
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    Stream(pdf, syllabus.course.code + "_" + syllabus.course.name + " 教学大纲.pdf").cleanup(() => pdf.delete())
  }

  def planPdf(): View = {
    val id = getLongId("plan")
    val plan = entityDao.get(classOf[ClazzPlan], id)
    val url = EmsApi.url(s"/info/syllabus/plan?plan.id=${plan.id}")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    Stream(pdf, plan.clazz.crn + "_" + plan.clazz.course.name + " 授课计划.pdf").cleanup(() => pdf.delete())
  }
}
