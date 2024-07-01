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
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.edu.course.model.Syllabus
import org.openurp.edu.course.web.helper.SyllabusHelper
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 课程大纲教研室审核
 */
class OfficeAction extends RestfulAction[Syllabus], ProjectSupport {

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
    val query = super.getQueryBuilder
    query.where("syllabus.course.project=:project", project)
    if (offices.nonEmpty) {
      query.where("syllabus.office in(:offices)", offices)
    }
    query.where("syllabus.reviewer.code=:reviewerCode", Securities.user)
    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    query
  }

  def audit(): View = {
    val statuses = auditStatuses
    val syllabuses = entityDao.find(classOf[Syllabus], getLongIds("syllabus")).filter(x => statuses.contains(x.status))
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDirector else AuditStatus.RejectedByDirector
      syllabuses foreach { s =>
        s.status = status
      }
    }
    entityDao.saveOrUpdate(syllabuses)
    val toInfo = getBoolean("toInfo", false)
    if (toInfo) redirect("info", "id=" + syllabuses.head.id, "审核成功")
    else redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val syllabus = entityDao.get(classOf[Syllabus], id.toLong)
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    val project = syllabus.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    put("auditable", auditStatuses.contains(syllabus.status))
    forward(s"/org/openurp/edu/course/web/components/syllabus/report_${syllabus.docLocale}")
  }

  private def auditStatuses: Seq[AuditStatus] = {
    Seq(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.Rejected)
  }
}
