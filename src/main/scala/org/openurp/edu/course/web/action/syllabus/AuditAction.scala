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

import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.openurp.base.model.{AuditStatus, Project, Semester, User}
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.course.model.Syllabus
import org.openurp.edu.course.web.helper.{SyllabusHelper, SyllabusPropertyExtractor, SyllabusValidator}
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 教学副院长审核
 */
class AuditAction extends RestfulAction[Syllabus], ProjectSupport, ExportSupport[Syllabus] {

  var businessLogger: WebBusinessLogger = _

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    put("statuses", auditStatuses)
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[Syllabus] = {
    given project: Project = getProject

    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    val semester = entityDao.get(classOf[Semester], getInt("semester.id", 0))
    put("semester", semester)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    query.where(":date between syllabus.beginOn and syllabus.endOn", semester.beginOn.plusDays(30))
    query.where("syllabus.status in(:statuses)", auditStatuses)
    queryByDepart(query, "syllabus.department")
    query
  }

  def audit(): View = {
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus"))
    val user = entityDao.findBy(classOf[User], "school" -> syllabuses.head.course.project.school, "code" -> Securities.user).headOption
    var hasErrors: Int = 0
    var processed: Seq[Syllabus] = null
    val toPassedStatuses = Set(AuditStatus.PassedByDirector, AuditStatus.RejectedByDepart)
    val toFailedStatuses = Set(AuditStatus.PassedByDirector, AuditStatus.PassedByDepart)

    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDepart else AuditStatus.RejectedByDepart
      if (status == AuditStatus.PassedByDepart) {
        val oks = syllabuses.filter { s => SyllabusValidator.validate(s).isEmpty && toPassedStatuses.contains(s.status) }
        oks foreach { s =>
          s.status = status
          s.approver = user
        }
        hasErrors = syllabuses.size - oks.size
        processed = oks
      } else {
        val oks = syllabuses.filter { s => toFailedStatuses.contains(s.status) }
        oks foreach { s =>
          s.status = status
          s.approver = user
        }
        hasErrors = syllabuses.size - oks.size
        processed = oks
      }
    }
    entityDao.saveOrUpdate(processed)
    val list = syllabuses.groupBy(_.status)
    list foreach { case (status, s) =>
      if (status == AuditStatus.PassedByDepart) {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"学院审核通过课程教学大纲:${h.course.code} ${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"学院审核通过${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      } else {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"学院驳回了课程教学大纲:${h.course.code} ${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"学院驳回了${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      }
    }
    val message = if hasErrors > 0 then s"审核成功${syllabuses.size - hasErrors},失败${hasErrors}个" else "审核成功"
    val toInfo = getBoolean("toInfo", false)
    if (toInfo) redirect("info", "id=" + syllabuses.head.id, message)
    else redirect("search", message)
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val syllabus = entityDao.get(classOf[Syllabus], id.toLong)
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    val project = syllabus.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
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
    List(AuditStatus.PassedByDirector,
      AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart)
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new SyllabusPropertyExtractor()
  }
}
