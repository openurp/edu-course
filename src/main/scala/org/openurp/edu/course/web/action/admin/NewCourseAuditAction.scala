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

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Course, CourseJournal}
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.code.edu.model.CourseRank
import org.openurp.edu.course.flow.{NewCourseApply, NewCourseCategory, NewCourseDepart}
import org.openurp.starter.web.support.ProjectSupport

/** 新开课程申请
 */
class NewCourseAuditAction extends RestfulAction[NewCourseApply], ProjectSupport {

  override def simpleEntityName: String = "apply"

  override protected def indexSetting(): Unit = {
    given project: Project = getProject

    var departs = getDeparts

    val courseDeparts = entityDao.getAll(classOf[NewCourseDepart]).map(_.depart)
    val diffs = departs.diff(courseDeparts)
    departs = departs.toBuffer.subtractAll(diffs).sortBy(_.code).toSeq
    put("departments", departs)
    put("categories", getCodes(classOf[NewCourseCategory]))
    put("ranks", getCodes(classOf[CourseRank]).filter(_.id < 3))
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[NewCourseApply] = {
    given project: Project = getProject

    val q = super.getQueryBuilder
    queryByDepart(q, "apply.department")
  }

  def audit(): View = {
    val apply = entityDao.get(classOf[NewCourseApply], getLongId("apply"))
    if (apply.status == AuditStatus.Passed) {
      return redirect("search", "已经审核完毕")
    }
    val c = new Course
    c.project = apply.project
    c.code = generateCode(apply)
    c.name = apply.name
    c.enName = apply.enName

    c.module = apply.module
    c.rank = apply.rank
    c.nature = apply.nature
    c.department = apply.department
    c.defaultCredits = apply.defaultCredits
    c.creditHours = apply.creditHours
    c.weekHours = apply.weekHours
    c.examMode = apply.examMode
    c.gradingMode = apply.gradingMode
    c.tags.addAll(apply.tags)
    apply.hours foreach { h =>
      c.addHour(h.nature, h.creditHours)
    }
    c.beginOn = apply.beginOn
    c.updatedAt = apply.updatedAt
    entityDao.saveOrUpdate(c)
    val cj = new CourseJournal(c, apply.beginOn)
    entityDao.saveOrUpdate(cj)

    apply.status = AuditStatus.Passed
    apply.code = Some(c.code)
    entityDao.saveOrUpdate(apply)

    redirect("search", "审核成功")
  }

  private def generateCode(apply: NewCourseApply): String = {
    val departCode = entityDao.findBy(classOf[NewCourseDepart], "depart", apply.department).headOption.map(_.code).getOrElse(apply.department.code)
    val creditCode =
      if apply.defaultCredits % 1 > 0.1 then
        apply.defaultCredits.toInt.toString + "H"
      else
        "0" + apply.defaultCredits.toInt.toString
    val rankCode = if apply.rank.get.id == CourseRank.Compulsory then "1" else "2"
    val categoryCode = apply.category.code

    val codePattern = s"%${departCode}___${creditCode}${rankCode}${categoryCode}%"
    val newCodePattern = s"%${departCode}___${creditCode}${rankCode}${categoryCode}NEW%"
    val q = OqlBuilder.from[String](classOf[Course].getName, "c")
    q.where("c.code like :pattern or c.code like :newPattern", codePattern, newCodePattern)
    q.select("c.code")
    val codes = entityDao.search(q)
    val seqCode =
      if (codes.nonEmpty) {
        val seq = codes.map(_.substring(departCode.length, departCode.length + 3).toInt).sorted
        var start = 1
        val iter = seq.iterator
        var found = false
        while (iter.hasNext && !found) {
          val n = iter.next
          if (n - start <= 1) {
            start = n
          } else {
            found = true
          }
        }
        Strings.leftPad((start + 1).toString, 3, '0')
      } else {
        "001"
      }
    s"${departCode}${seqCode}${creditCode}${rankCode}${categoryCode}NEW"
  }

}
