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
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.edu.course.model.ClazzPlan
import org.openurp.edu.course.web.helper.ClazzPlanHelper
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 学院审核授课计划
 */
class AuditAction extends RestfulAction[ClazzPlan], ProjectSupport {

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

  override protected def getQueryBuilder: OqlBuilder[ClazzPlan] = {
    put("locales", Map(Locales.chinese -> "中文", Locales.us -> "English"))
    val query = super.getQueryBuilder
    query.where("clazzPlan.status in(:statuses)", auditStatuses)
    queryByDepart(query, "clazzPlan.clazz.teachDepart")
    query
  }

  def audit(): View = {
    val statuses = auditStatuses
    val plans1 = entityDao.find(classOf[ClazzPlan], getLongIds("clazzPlan"))
    val plans = plans1.filter(x => statuses.contains(x.status))
    val approver = entityDao.findBy(classOf[User], "school" -> plans.head.clazz.project.school, "code" -> Securities.user).headOption
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDepart else AuditStatus.RejectedByDepart
      plans foreach { s =>
        s.status = status
        s.approver = approver
      }
    }
    entityDao.saveOrUpdate(plans)
    val list = plans.groupBy(_.status)
    list foreach { case (status, s) =>
      if (status == AuditStatus.PassedByDepart) {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"审核通过课程授课计划:${h.clazz.course.name}(${h.clazz.crn})", h.id, Map("clazzPlan" -> h.id.toString))
        } else {
          businessLogger.info(s"审核通过${s.size}个课程授课计划", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      } else {
        if (s.size == 1) {
          val h = s.head
          businessLogger.info(s"驳回了课程授课计划:${h.clazz.course.name}(${h.clazz.crn})", h.id, Map("clazzPlan" -> h.id.toString))
        } else {
          businessLogger.info(s"驳回了${s.size}个课程授课计划", s.head.id, Map("ids" -> s.map(_.id.toString).mkString(",")))
        }
      }
    }
    val toInfo = getBoolean("toInfo", false)
    if (toInfo) redirect("info", "id=" + plans1.head.id, "审核成功")
    else redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[ClazzPlan], id.toLong)
    new ClazzPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    val project = plan.clazz.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    put("auditable", auditStatuses.contains(plan.status))
    forward(s"/org/openurp/edu/course/web/components/plan/report_zh_CN")
  }

  private def auditStatuses: Seq[AuditStatus] = {
    List(AuditStatus.PassedByDirector, AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart)
  }
}
