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

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.{Numbers, Strings}
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Course, CourseJournal}
import org.openurp.base.model.AuditStatus.{Passed, Rejected}
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.code.edu.model.*
import org.openurp.edu.course.flow.{NewCourseApply, NewCourseCategory, NewCourseDepart}
import org.openurp.edu.course.service.NewCourseApplyService
import org.openurp.starter.web.support.ProjectSupport

/** 新开课程申请
 */
class NewCourseAuditAction extends RestfulAction[NewCourseApply], ProjectSupport {

  override def simpleEntityName: String = "apply"

  var newCourseApplyService: NewCourseApplyService = _

  override protected def indexSetting(): Unit = {
    given project: Project = getProject

    var departs = getDeparts

    val courseDeparts = entityDao.getAll(classOf[NewCourseDepart]).map(_.depart)
    val diffs = departs.diff(courseDeparts)
    departs = departs.toBuffer.subtractAll(diffs).sortBy(_.code).toSeq
    put("departments", departs)
    put("categories", getCodes(classOf[NewCourseCategory]))
    put("ranks", getCodes(classOf[CourseRank]).filter(_.id < 3))
    put("statuses", Seq(AuditStatus.Submited, AuditStatus.Passed, AuditStatus.Rejected))
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[NewCourseApply] = {
    given project: Project = getProject

    val q = super.getQueryBuilder
    queryByDepart(q, "apply.department")
  }

  def auditSetting(): View = {
    given project: Project = getProject

    val apply = entityDao.get(classOf[NewCourseApply], getLongId("apply"))
    put("apply", apply)
    put("natures", getCodes(classOf[CourseNature]))
    put("modules", getCodes(classOf[CourseModule]))
    put("ranks", entityDao.find(classOf[CourseRank], List(CourseRank.Compulsory, CourseRank.Selective)))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("categories", getCodes(classOf[NewCourseCategory]))
    put("examModes", getCodes(classOf[ExamMode]))
    put("gradingModes", getCodes(classOf[GradingMode]))
    put("tags", codeService.get(classOf[CourseTag]))
    forward()
  }

  def regen(): View = {
    val apply = entityDao.get(classOf[NewCourseApply], getLongId("apply"))
    if (apply.code.isEmpty) {
      redirect("search", "请选择审批通过的申请")
    } else {
      val oldCode = apply.code.get
      val newCode = generateCode(apply)
      apply.code = Some(newCode)
      val courses = entityDao.findBy(classOf[Course], "project" -> apply.project, "code" -> oldCode)
      courses foreach { c =>
        c.code = newCode
      }
      entityDao.saveOrUpdate(courses)
      entityDao.saveOrUpdate(apply)
      redirect("search", "生成完成")
    }
  }

  /** 单个课程审核
   *
   * @return
   */
  def audit(): View = {
    val failed = Collections.newBuffer[String]
    val apply = this.populateEntity(classOf[NewCourseApply], "apply")
    if (apply.status == AuditStatus.Passed) {
      return redirect("search", "已经通过无需再审")
    }
    val passed = getBoolean("passed", false)
    if (passed) {
      if (apply.code.nonEmpty) {
        apply.status = Passed
        entityDao.saveOrUpdate(apply)
        return redirect("search", "审核成功")
      }
      val errors = newCourseApplyService.check(apply)
      if (errors.nonEmpty) {
        return redirect("search", errors.mkString(","))
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
    } else {
      apply.status = Rejected
      entityDao.saveOrUpdate(apply)
    }
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

    val seqCode = getSeq(apply, 3)
    s"${departCode}${seqCode}${creditCode}${rankCode}${categoryCode}NEW"
  }

  private def getSeq(apply: NewCourseApply, seqLength: Int): String = {
    val departCode = entityDao.findBy(classOf[NewCourseDepart], "depart", apply.department).headOption.map(_.code).getOrElse(apply.department.code)
    val codePattern = s"${departCode}" + ("_" * seqLength) + "%"
    val q = OqlBuilder.from[String](classOf[Course].getName, "c")
    q.where("c.code like :pattern and c.name=:name", codePattern, apply.name)
    q.where("c.project=:project", apply.project)
    q.select("c.code")
    val exists = entityDao.search(q)
    if (exists.nonEmpty) {
      exists.head.substring(departCode.length, departCode.length + seqLength) //从第二位开始取，取三位
    } else {
      val q = OqlBuilder.from[String](classOf[Course].getName, "c")
      q.where("c.code like :pattern", codePattern)
      q.where("c.project=:project", apply.project)
      q.select("c.code")
      val codes = entityDao.search(q)
      if (codes.nonEmpty) {
        val seq = codes.map(_.substring(departCode.length, departCode.length + seqLength)).filter(x => Numbers.isDigits(x)).map(_.toInt).distinct.sorted
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
        Strings.leftPad((start + 1).toString, seqLength, '0')
      } else {
        Strings.leftPad("1", seqLength, '0')
      }
    }
  }
}
