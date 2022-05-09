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

package org.openurp.edu.course.web.action

import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.EmsApp
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.{Status, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, Terms}
import org.openurp.base.model.AuditStatus
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseProfile, Syllabus, SyllabusFile}
import org.openurp.edu.course.web.helper.{PlanCourseInfo, StatHelper}
import org.openurp.edu.program.model.{ExecutionPlanCourse, PlanCourse}
import org.openurp.starter.edu.helper.ProjectSupport

import java.time.LocalDate

class InfoAction extends ActionSupport with EntityAction[Course] with ProjectSupport {

  def index(): View = {
    val dQuery = OqlBuilder.from(classOf[Course].getName, "c")
    dQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    dQuery.select("c.department.id,c.department.name,count(*)")
    dQuery.groupBy("c.department.id,c.department.code,c.department.name")
    dQuery.orderBy("c.department.code")
    put("departStat", entityDao.search(dQuery))

    val ctQuery = OqlBuilder.from(classOf[Course].getName, "c")
    ctQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    ctQuery.select("c.courseType.id,c.courseType.name,count(*)")
    ctQuery.groupBy("c.courseType.id,c.courseType.code,c.courseType.name")
    ctQuery.orderBy("c.courseType.code")
    put("typeStat", entityDao.search(ctQuery))

    val ccQuery = OqlBuilder.from(classOf[Course].getName, "c")
    ccQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    ccQuery.select("c.nature.id,c.nature.name,count(*)")
    ccQuery.groupBy("c.nature.id,c.nature.code,c.nature.name")
    ccQuery.orderBy("c.nature.code")
    put("natureStat", entityDao.search(ccQuery))

    forward()
  }

  def search(): View = {
    val query = getQueryBuilder
    get("q") foreach { q =>
      query.where("course.code like :q or course.name like :q", s"%${q.trim}%")
    }
    query.where("course.endOn is null or course.endOn > :now", LocalDate.now)
    query.orderBy("course.code")
    getBoolean("hasClazz") foreach {
      case true => query.where("exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
      case false => query.where("not exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
    }
    put("courses", entityDao.search(query))
    forward()
  }

  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val course = getModel[Course](entityName, convertId(id))
    put(simpleEntityName, course)

    val profileQuery = OqlBuilder.from(classOf[CourseProfile], "cp")
    profileQuery.where("cp.course = :course", course)
    put("profile", entityDao.search(profileQuery).headOption)

    val syllabusQuery = OqlBuilder.from(classOf[Syllabus], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.where("s.status=:publishsed", AuditStatus.Published)
    syllabusQuery.orderBy("s.updatedAt desc")
    put("syllabuses", entityDao.search(syllabusQuery))

    val statHelper = new StatHelper(entityDao)
    put("clazzInfos", statHelper.statClazzInfo(course))
    put("planCourseInfos", statHelper.statPlanCourseInfo(course))
    forward()
  }

  /** 下载下载发布的大纲 */
  def attachment(): View = {
    val file = entityDao.get(classOf[SyllabusFile], longId("file"))
    if (file.syllabus.status == AuditStatus.Published) {
      val path = EmsApp.getBlobRepository(true).url(file.filePath)
      response.sendRedirect(path.get.toString)
      null
    } else {
      Status.NotFound
    }
  }
}
