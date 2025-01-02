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

package org.openurp.edu.course.web.action.syllabus

import org.beangle.commons.lang.Locales
import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.support.action.RestfulAction
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.{AuditStatus, Project, Semester, User}
import org.openurp.edu.course.model.Syllabus
import org.openurp.edu.course.web.helper.{SyllabusHelper, SyllabusValidator}
import org.openurp.starter.web.helper.ProjectProfile
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 课程大纲教研室审核
 */
class OfficeAction extends RestfulAction[Syllabus], ProjectSupport {

  var businessLogger: WebBusinessLogger = _

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

  override protected def getQueryBuilder: OqlBuilder[Syllabus] = {
    val project = getProject
    val offices = getOffices(project)
    val semester = entityDao.get(classOf[Semester], getInt("semester.id", 0))
    put("semester", semester)
    val query = super.getQueryBuilder
    query.where(":date between syllabus.beginOn and syllabus.endOn", semester.beginOn.plusDays(30))
    query.where("syllabus.course.project=:project", project)
    if (offices.nonEmpty) {
      query.where("syllabus.office in(:offices)", offices)
    }
    put("locales", Map(Locales.chinese -> "中文", Locales.us -> "English"))
    query
  }

  def audit(): View = {
    val statuses = auditStatuses
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus")).filter(x => statuses.contains(x.status))
    var hasErrors: Int = 0
    var processed: Seq[Syllabus] = null
    val toPassedStatuses = Set(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart)
    val toFailedStatuses = Set(AuditStatus.Submited, AuditStatus.PassedByDirector)

    val reviewer = entityDao.findBy(classOf[User], "school" -> syllabuses.head.course.project.school, "code" -> Securities.user).headOption

    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDirector else AuditStatus.RejectedByDirector
      if (status == AuditStatus.PassedByDirector) {
        val oks = syllabuses.filter { s => SyllabusValidator.validate(s).isEmpty && toPassedStatuses.contains(s.status) }
        oks foreach { s =>
          s.status = status
          s.reviewer = reviewer
        }
        hasErrors = syllabuses.size - oks.size
        processed = oks
      } else {
        val oks = syllabuses.filter { s => toFailedStatuses.contains(s.status) }
        oks foreach { s =>
          s.status = status
          s.reviewer = reviewer
        }
        hasErrors = syllabuses.size - oks.size
        processed = oks
      }
    }
    entityDao.saveOrUpdate(processed)

    val list = processed.groupBy(_.status)
    list foreach { case (status, s) =>
      if (status == AuditStatus.PassedByDirector) {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"教研室审核通过课程教学大纲:${h.course.code} ${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"教研室审核通过${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      } else {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"教研室驳回了课程教学大纲:${h.course.code} ${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"教研室驳回了${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      }
    }
    val message = if hasErrors > 0 then s"审核成功${syllabuses.size - hasErrors}个 失败${hasErrors}个" else "审核成功"
    val toInfo = getBoolean("toInfo", false)
    if (toInfo) redirect("info", "id=" + syllabuses.head.id, message)
    else redirect("search", message)
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val syllabus = entityDao.get(classOf[Syllabus], id.toLong)
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    val project = syllabus.course.project
    ProjectProfile.set(project)
    put("auditable", auditStatuses.contains(syllabus.status))
    val messages = SyllabusValidator.validate(syllabus)
    put("messages", messages)
    val semester = getInt("semester.id") match
      case Some(sid) => entityDao.get(classOf[Semester], sid)
      case None => syllabus.semester
    put("semester", semester)
    forward(s"/org/openurp/edu/course/web/components/syllabus/report_${syllabus.docLocale}")
  }

  private def auditStatuses: Seq[AuditStatus] = {
    Seq(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.Rejected)
  }
}
