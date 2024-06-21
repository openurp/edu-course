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
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.course.model.Syllabus
import org.openurp.edu.course.web.helper.{SyllabusHelper, SyllabusPropertyExtractor}
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

    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    query.where("syllabus.status in(:statuses)", auditStatuses)
    query
  }

  def audit(): View = {
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus"))
    val user = entityDao.findBy(classOf[User], "school" -> syllabuses.head.course.project.school, "code" -> Securities.user).headOption
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDepart else AuditStatus.RejectedByDepart
      syllabuses foreach { s =>
        s.status = status
        s.approver = user
      }
    }
    entityDao.saveOrUpdate(syllabuses)
    val list = syllabuses.groupBy(_.status)
    list foreach { case (status, s) =>
      if (status == AuditStatus.PassedByDepart) {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"审核通过课程教学大纲:${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"审核通过${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      } else {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"驳回了课程教学大纲:${h.course.name}", h.id, Map("syllabus" -> h.id.toString))
        } else {
          businessLogger.info(s"驳回了${s.size}个课程教学大纲", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      }
    }
    redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val syllabus = entityDao.get(classOf[Syllabus], id.toLong)
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    forward(s"/org/openurp/edu/course/syllabus/${syllabus.course.project.school.id}/${syllabus.course.project.id}/report_${syllabus.locale}")
  }

  private def auditStatuses: Seq[AuditStatus] = {
    List(AuditStatus.PassedByDirector,
      AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart,
      AuditStatus.Rejected, AuditStatus.Passed)
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new SyllabusPropertyExtractor()
  }
}
