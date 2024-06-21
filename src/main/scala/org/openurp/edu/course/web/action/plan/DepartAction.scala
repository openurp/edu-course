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

import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.edu.course.model.{Syllabus, TeachingPlan}
import org.openurp.edu.course.web.helper.{CourseTaskPropertyExtractor, SyllabusPropertyExtractor, TeachingPlanHelper}
import org.openurp.starter.web.support.ProjectSupport

import java.util.Locale

/** 学院查询教学大纲
 */
class DepartAction extends RestfulAction[TeachingPlan], ProjectSupport {
  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    put("statuses", List(AuditStatus.Draft, AuditStatus.Submited,
      AuditStatus.RejectedByDirector, AuditStatus.PassedByDirector,
      AuditStatus.RejectedByDepart, AuditStatus.PassedByDepart,
      AuditStatus.Rejected, AuditStatus.Passed))
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[TeachingPlan] = {
    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    super.getQueryBuilder
  }

  def audit(): View = {
    val plans = entityDao.find(classOf[TeachingPlan], getLongIds("syllabus"))
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDepart else AuditStatus.RejectedByDepart
      plans foreach { s => s.status = status }
    }
    entityDao.saveOrUpdate(plans)
    redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[TeachingPlan], id.toLong)
    new TeachingPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    forward(s"/org/openurp/edu/course/lesson/${plan.clazz.project.school.id}/${plan.clazz.project.id}/report")
  }

}
