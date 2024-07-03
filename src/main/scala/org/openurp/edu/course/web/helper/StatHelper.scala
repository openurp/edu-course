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

package org.openurp.edu.course.web.helper

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.edu.model.{Course, CourseProfile, Terms}
import org.openurp.base.hr.model.Teacher
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.SyllabusDoc
import org.openurp.edu.program.model.{ExecutivePlanCourse, PlanCourse}

import java.time.LocalDate

class StatHelper(entityDao: EntityDao) {

  def statClazzInfo(course: Course): Iterable[ClazzInfo] = {
    val clazzQuery = OqlBuilder.from(classOf[Clazz], "c")
    clazzQuery.where("c.project=:project",course.project)
    clazzQuery.where("c.course=:course", course)
    clazzQuery.where("c.semester.beginOn > :yearBefore", LocalDate.now().minusYears(10))
    val clazzes = entityDao.search(clazzQuery)
    val clazzInfos = clazzes.groupBy(x => (x.course, x.semester, x.teachDepart))
      .map(x => ClazzInfo(x._1._1, x._1._2, x._1._3, collectTeachers(x._2), x._2.size))
    clazzInfos.toList.sortBy(x => x.semester.beginOn.toString)(Ordering.String.reverse)
  }

  def statPlanCourseInfo(course: Course): Iterable[PlanCourseInfo] = {
    val pQuery = OqlBuilder.from(classOf[ExecutivePlanCourse], "pc")
    pQuery.where("pc.course=:course", course)
    val today = LocalDate.now
    pQuery.where(":today < pc.group.plan.program.endOn", today)
    val pcs = entityDao.search(pQuery)
    val pcis = pcs.groupBy(x => (x.course, x.group.courseType, x.group.plan.program.grade))
      .map { x =>
        val levels = x._2.map(_.group.plan.program.level).toSet
        val levelsList = levels.toList.sortBy(_.code)
        val majors = x._2.map(_.group.plan.program.major).toSet
        val majorList = majors.toList.sortBy(x => x.code)
        PlanCourseInfo(x._1._1, x._1._2, x._1._3.code, levelsList, majorList, collectTerms(x._2), x._2.size)
      }
    pcis.toList.sortBy(x => x.grade)(Ordering.String.reverse)
  }

  def hasSyllabus(courses: Iterable[Course]): collection.Set[Long] = {
    val pQuery = OqlBuilder.from[Long](classOf[SyllabusDoc].getName, "cp")
    pQuery.where("cp.course in(:course)", courses)
    pQuery.select("cp.course.id")
    entityDao.search(pQuery).toSet
  }

  def hasProfile(courses: Iterable[Course]): collection.Set[Long] = {
    val sQuery = OqlBuilder.from[Long](classOf[CourseProfile].getName, "s")
    sQuery.where("s.course in(:course)", courses)
    sQuery.select("s.course.id")
    entityDao.search(sQuery).toSet
  }

  private def collectTerms(pcs: Iterable[PlanCourse]): Terms = {
    var t = 0
    pcs.foreach(x => t = t | x.terms.value)
    new Terms(t)
  }

  private def collectTeachers(clazzes: Iterable[Clazz]): Iterable[Teacher] = {
    val teachers = clazzes.flatMap(_.teachers).toSet
    teachers.toList.sortBy(x => x.staff.name)
  }

}
