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

package org.openurp.edu.course.web.action.admin

import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.AuditStatus.Submited
import org.openurp.base.model.{Project, User}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.*
import org.openurp.edu.course.flow.{NewCourseApply, NewCourseApplyHour, NewCourseCategory, NewCourseDepart}
import org.openurp.starter.web.support.ProjectSupport

import java.time.{Instant, LocalDate}

/** 新开课程申请
 */
class NewCourseApplyAction extends RestfulAction[NewCourseApply], ProjectSupport {

  override def simpleEntityName: String = "apply"

  override protected def indexSetting(): Unit = {
    given project: Project = getProject

    put("departments", getDeparts)
    put("categories", getCodes(classOf[NewCourseCategory]))
    put("ranks", getCodes(classOf[CourseRank]).filter(_.id < 3))
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[NewCourseApply] = {
    given project: Project = getProject

    val q = super.getQueryBuilder
    queryByDepart(q, "apply.department")
  }

  override def editSetting(entity: NewCourseApply): Unit = {
    //    if(entity.status!=null && entity.status==AuditStatus.Passed){
    //
    //    }
    given project: Project = getProject

    var departs = getDeparts.toSet
    val courseDeparts = entityDao.getAll(classOf[NewCourseDepart]).sortBy(_.code).map(_.depart).filter(x => departs.contains(x))
    put("departments", courseDeparts)

    put("natures", getCodes(classOf[CourseNature]))
    put("modules", getCodes(classOf[CourseModule]))
    put("ranks", getCodes(classOf[CourseRank]).filter(_.id < 3))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("categories", getCodes(classOf[NewCourseCategory]))
    put("gradingModes", getCodes(classOf[GradingMode]))
    put("tags", codeService.get(classOf[CourseTag]))
    entity.project = project
    super.editSetting(entity)
  }

  override protected def saveAndRedirect(apply: NewCourseApply): View = {
    given project: Project = getProject

    apply.project = project
    apply.updatedAt = Instant.now
    if (null == apply.beginOn) {
      val q = OqlBuilder.from(classOf[Grade], "g")
      q.where("g.project=:project", project)
      q.where("g.beginOn >:now ", LocalDate.now)
      q.orderBy("g.beginOn ")
      val beginOn = entityDao.first(q).map(_.beginOn).getOrElse(LocalDate.now)
      apply.beginOn = beginOn
    }
    apply.status = Submited
    apply.applicant = entityDao.findBy(classOf[User], "school" -> project.school, "code" -> Securities.user).head

    val teachingNatures = getCodes(classOf[TeachingNature])
    teachingNatures foreach { ht =>
      val creditHour = getInt("creditHour" + ht.id)
      val week = getInt("week" + ht.id)
      apply.hours find (h => h.nature == ht) match {
        case Some(hour) =>
          if (week.isEmpty && creditHour.isEmpty) {
            apply.hours -= hour
          } else {
            hour.weeks = week.getOrElse(0)
            hour.creditHours = creditHour.getOrElse(0)
          }
        case None =>
          if (!(week.isEmpty && creditHour.isEmpty)) {
            val newHour = new NewCourseApplyHour()
            newHour.courseApply = apply
            newHour.nature = ht
            newHour.weeks = week.getOrElse(0)
            newHour.creditHours = creditHour.getOrElse(0)
            apply.hours += newHour
          }
      }
    }
    val orphan = apply.hours.filter(x => !teachingNatures.contains(x.nature))
    apply.hours --= orphan

    apply.tags.clear()
    apply.tags.addAll(entityDao.find(classOf[CourseTag], getIntIds("tag")))

    super.saveAndRedirect(apply)
  }
}
