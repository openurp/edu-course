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

package org.openurp.edu.course.web.action.plan

import org.beangle.commons.lang.Locales
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.support.action.RestfulAction
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.AuditStatus.RejectedByDepart
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.edu.course.model.ClazzPlan
import org.openurp.edu.course.web.helper.ClazzPlanHelper
import org.openurp.starter.web.helper.ProjectProfile
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 课程大纲教研室审核
 */
class OfficeAction extends RestfulAction[ClazzPlan], ProjectSupport {

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    put("project", project)
    put("semester", getSemester)
    put("offices", getOffices(project))
    put("statuses", auditStatuses)
    forward()
  }

  private def getOffices(project: Project): Seq[TeachingOffice] = {
    val q = OqlBuilder.from(classOf[TeachingOffice], "o")
    q.where("o.project = :project", project)
    q.where("o.director.staff.code = :me", Securities.user)
    entityDao.search(q)
  }

  override protected def getQueryBuilder: OqlBuilder[ClazzPlan] = {
    val project = getProject
    val query = super.getQueryBuilder
    query.where("clazzPlan.clazz.course.project=:project", project)
    query.where("clazzPlan.status in(:statuses)", searchStatuses)
    val offices = getOffices(project)
    if (offices.nonEmpty) {
      query.where("clazzPlan.office in(:offices)", offices)
    }
    query.where("clazzPlan.reviewer.code=:reviewerCode", Securities.user)
    put("locales", Map(Locales.chinese -> "中文", Locales.us -> "English"))
    query
  }

  def audit(): View = {
    val statuses = auditStatuses
    val plans = entityDao.find(classOf[ClazzPlan], getLongIds("clazzPlan")).filter(x => statuses.contains(x.status))
    val user = entityDao.findBy(classOf[User], "school" -> plans.head.clazz.project.school, "code" -> Securities.user).headOption

    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDirector else AuditStatus.RejectedByDirector
      plans foreach { s =>
        s.reviewer = user
        s.status = status
      }
    }
    entityDao.saveOrUpdate(plans)
    val toInfo = getBoolean("toInfo", false)
    if (toInfo) redirect("info", "id=" + plans.head.id, "审核成功")
    else redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[ClazzPlan], id.toLong)
    new ClazzPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    val project = plan.clazz.course.project
    ProjectProfile.set(project)
    put("auditable", auditStatuses.contains(plan.status))
    forward(s"/org/openurp/edu/course/web/components/plan/report_zh_CN")
  }

  private def auditStatuses: Seq[AuditStatus] = {
    Seq(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart)
  }

  private def searchStatuses: Seq[AuditStatus] = {
    Seq(AuditStatus.Submited, AuditStatus.PassedByDirector, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart)
  }
}
