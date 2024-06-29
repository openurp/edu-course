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

import org.beangle.commons.concurrent.Workers
import org.beangle.commons.file.zip.Zipper
import org.beangle.commons.io.Files
import org.beangle.commons.lang.SystemInfo
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.ems.app.Ems
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.{Stream, View}
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.TeachingOffice
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.edu.course.model.TeachingPlan
import org.openurp.edu.course.web.helper.TeachingPlanHelper
import org.openurp.starter.web.support.ProjectSupport

import java.io.File
import java.net.URI
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

  override protected def removeAndRedirect(plans: Seq[TeachingPlan]): View = {
    val removables = Seq(AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart, AuditStatus.Draft)
    super.removeAndRedirect(plans.filter(x => removables.contains(x.status)))
  }

  override protected def getQueryBuilder: OqlBuilder[TeachingPlan] = {
    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    val query = super.getQueryBuilder
    getInt("checkHour") foreach {
      case 1 => query.where("teachingPlan.lessonHours + teachingPlan.examHours > teachingPlan.clazz.course.creditHours")
      case 0 => query.where("teachingPlan.lessonHours + teachingPlan.examHours = teachingPlan.clazz.course.creditHours")
      case -1 => query.where("teachingPlan.lessonHours>0 and teachingPlan.lessonHours + teachingPlan.examHours < teachingPlan.clazz.course.creditHours")
      case _ =>
    }
    queryByDepart(query, "teachingPlan.clazz.teachDepart")
  }

  def audit(): View = {
    val plans = entityDao.find(classOf[TeachingPlan], getLongIds("syllabus"))
    getBoolean("passed") foreach { passed =>
      val status = if passed then AuditStatus.PassedByDepart else AuditStatus.RejectedByDepart
      plans foreach { s =>
        s.status = status
      }
    }
    entityDao.saveOrUpdate(plans)
    redirect("search", "审核成功")
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val plan = entityDao.get(classOf[TeachingPlan], id.toLong)
    new TeachingPlanHelper(entityDao).collectDatas(plan) foreach { case (k, v) => put(k, v) }
    val project = plan.clazz.course.project
    ProfileTemplateLoader.setProfile(s"${project.school.id}/${project.id}")
    forward(s"/org/openurp/edu/course/web/components/plan/report_zh_CN")
  }

  override protected def editSetting(plan: TeachingPlan): Unit = {
    given project: Project = getProject

    put("offices", entityDao.findBy(classOf[TeachingOffice], "project" -> project, "department" -> plan.clazz.teachDepart))
    super.editSetting(plan)
  }

  def download(): View = {
    val teachingPlans = entityDao.find(classOf[TeachingPlan], getLongIds("teachingPlan"))
    val pdfDir = SystemInfo.tmpDir + "/" + s"teachingPlan_${Securities.user}"
    Files.travel(new File(pdfDir), f => f.delete())
    val contextPath = ActionContext.current.request.getContextPath
    new File(pdfDir).mkdirs()
    if (teachingPlans.size == 1) {
      val plan = teachingPlans.head
      val url = Ems.base + contextPath + s"/plan/depart/${plan.id}?URP_SID=" + Securities.session.map(_.id).getOrElse("")
      val fileName = Files.purify(plan.clazz.crn + "_" + plan.clazz.course.name + "_授课计划")
      val pdf = new File(pdfDir + s"/${fileName}.pdf")
      val options = new PrintOptions
      SPDConverter.getInstance().convert(URI.create(url), pdf, options)
      Stream(pdf).cleanup { () =>
        pdf.delete()
        new File(pdfDir).delete()
      }
    } else {
      val datas = teachingPlans.map(x => (x.id, Files.purify(x.clazz.crn + "_" + x.clazz.course.name + "_授课计划")))
      Workers.work(datas, (data: (Long, String)) => {
        val url = Ems.base + contextPath + s"/plan/depart/${data._1}?URP_SID=" + Securities.session.map(_.id).getOrElse("")
        val pdf = new File(pdfDir + s"/${data._2}.pdf")
        val options = new PrintOptions
        SPDConverter.getInstance().convert(URI.create(url), pdf, options)
      }, Runtime.getRuntime.availableProcessors)
      val zipFile = new File(SystemInfo.tmpDir + s"/archive${Securities.user}.zip")
      Zipper.zip(new File(pdfDir), zipFile, "utf-8")
      Stream(zipFile).cleanup { () =>
        zipFile.delete()
        Files.travel(new File(pdfDir), f => f.delete())
      }
    }
  }
}
