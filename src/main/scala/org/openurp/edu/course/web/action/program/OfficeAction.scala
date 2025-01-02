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

import org.beangle.commons.lang.Locales
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.{Project, Semester}
import org.openurp.edu.course.model.{ClazzProgram, CourseTask, Syllabus}
import org.openurp.starter.web.support.ProjectSupport

class OfficeAction extends DepartAction {

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    put("project", project)
    put("semester", getSemester)
    put("offices", getOffices(project))
    forward()
  }

  private def getOffices(project: Project): Seq[TeachingOffice] = {
    val q = OqlBuilder.from(classOf[TeachingOffice], "o")
    q.where("o.project = :project", project)
    q.where("o.director.staff.code = :me", Securities.user)
    entityDao.search(q)
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
    val project = getProject
    val offices = getOffices(project)
    if (offices.nonEmpty) {
      val q = OqlBuilder.from(classOf[CourseTask], "ct")
      q.where("ct.office in(:offices)", offices)
      q.select("ct.course")
      val courses = entityDao.search(q)
      if (courses.nonEmpty)
        query.where("clazzProgram.clazz.course in(:courses)", courses)
      else
        query.where("clazzProgram.id <0")
    } else {
      query.where("clazzProgram.id <0")
    }
    query
  }

}
