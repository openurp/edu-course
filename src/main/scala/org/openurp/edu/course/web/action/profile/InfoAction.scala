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

package org.openurp.edu.course.web.action.profile

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.EmsApp
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.{Status, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, CourseProfile}
import org.openurp.base.model.AuditStatus
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.SyllabusDoc
import org.openurp.edu.course.web.helper.StatHelper
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate

class InfoAction extends ActionSupport, EntityAction[Course], ProjectSupport {

  var entityDao: EntityDao = _

  def index(): View = {
    val project = getProject
    val dQuery = OqlBuilder.from(classOf[Course].getName, "c")
    dQuery.where("c.project=:project", project)
    dQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    dQuery.select("c.department.id,c.department.name,count(*)")
    dQuery.groupBy("c.department.id,c.department.code,c.department.name")
    dQuery.orderBy("count(*) desc,c.department.name")
    put("departStat", entityDao.search(dQuery))

    val ctQuery = OqlBuilder.from(classOf[Course].getName, "c")
    ctQuery.where("c.project=:project", project)
    ctQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    ctQuery.select("c.courseType.id,c.courseType.name,count(*)")
    ctQuery.groupBy("c.courseType.id,c.courseType.code,c.courseType.name")
    ctQuery.orderBy("count(*) desc,c.courseType.code")
    put("typeStat", entityDao.search(ctQuery))

    val ccQuery = OqlBuilder.from(classOf[Course].getName, "c")
    ccQuery.where("c.project=:project", project)
    ccQuery.where("c.endOn is null or c.endOn > :now", LocalDate.now)
    ccQuery.select("c.nature.id,c.nature.name,count(*)")
    ccQuery.groupBy("c.nature.id,c.nature.code,c.nature.name")
    ccQuery.orderBy("count(*) desc,c.nature.code")
    put("natureStat", entityDao.search(ccQuery))

    forward()
  }

  def search(): View = {
    val project = getProject
    val query = getQueryBuilder
    get("q") foreach { q =>
      query.where("course.code like :q or course.name like :q", s"%${q.trim}%")
    }
    query.where("course.endOn is null or course.endOn > :now", LocalDate.now)
    query.where("course.project=:project", project)
    query.orderBy("course.code")
    getInt("hasClazz") foreach {
      case 1 => query.where("exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
      case 0 => query.where("not exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
      case -5 =>
        query.where("exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
        query.where("not exists(from " + classOf[Clazz].getName +
          " clz where clz.course=course and clz.semester.beginOn > :yearBefore)", LocalDate.now().plusYears(-5))
      case 5 =>
        query.where("exists(from " + classOf[Clazz].getName +
          " clz where clz.course=course and clz.semester.beginOn > :yearBefore)", LocalDate.now().plusYears(-5))
      case _ =>
    }
    put("courses", entityDao.search(query))
    forward()
  }

  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    put(simpleEntityName, course)

    val profileQuery = OqlBuilder.from(classOf[CourseProfile], "cp")
    profileQuery.where("cp.course = :course", course)
    profileQuery.orderBy("cp.beginOn desc")
    put("profile", entityDao.first(profileQuery))

    val docQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    docQuery.where("s.course = :course", course)
    docQuery.where("s.status=:publishsed", AuditStatus.Published)
    docQuery.orderBy("s.updatedAt desc")
    put("syllabusDocs", entityDao.search(docQuery))

    val statHelper = new StatHelper(entityDao)
    put("clazzInfos", statHelper.statClazzInfo(course))
    put("planCourseInfos", statHelper.statPlanCourseInfo(course))
    forward()
  }

  /** 下载下载发布的大纲 */
  def attachment(): View = {
    val doc = entityDao.get(classOf[SyllabusDoc], getLongId("doc"))
    if (doc.status == AuditStatus.Published) {
      val path = EmsApp.getBlobRepository(true).url(doc.docPath)
      response.sendRedirect(path.get.toString)
      null
    } else {
      Status.NotFound
    }
  }
}
