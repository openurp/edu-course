/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.edu.course.web.action

import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.api.action.ActionSupport
import org.beangle.webmvc.api.annotation.{mapping, param}
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.EntityAction
import org.openurp.base.edu.model.{Course, Teacher}
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseProfile, Syllabus, SyllabusStatus}
import org.openurp.edu.course.web.helper.ClazzInfo
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
    syllabusQuery.where("s.status=:publishsed", SyllabusStatus.Published)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    put("syllabuses", entityDao.search(syllabusQuery))

    val clazzQuery = OqlBuilder.from(classOf[Clazz], "c")
    clazzQuery.where("c.course=:course", course)
    clazzQuery.where("c.semester.beginOn > :yearBefore", LocalDate.now().plusYears(-5))
    val clazzes = entityDao.search(clazzQuery)
    val clazzInfos = clazzes.groupBy(x => (x.course, x.semester, x.teachDepart))
      .map(x => ClazzInfo(x._1._1, x._1._2, x._1._3, collectTeachers(x._2), x._2.size))
    put("clazzInfos", clazzInfos.toList.sortBy(x => x.semester.beginOn.toString)(Ordering.String.reverse))
    forward()
  }

  private def collectTeachers(clazzes: Iterable[Clazz]): Iterable[Teacher] = {
    clazzes.map(_.teachers).flatten.toSet
  }
}
