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

package org.openurp.edu.course.web.action.experiment

import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.webmvc.support.action.{ExportSupport, RestfulAction}
import org.openurp.base.model.{AuditStatus, Project, Semester}
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.course.model.SyllabusExperiment
import org.openurp.edu.course.web.helper.SyllabusExperimentPropertyExtractor
import org.openurp.starter.web.support.ProjectSupport

/**
 * 学院管理实验项目
 */
class DepartAction extends RestfulAction[SyllabusExperiment], ProjectSupport, ExportSupport[SyllabusExperiment] {

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

  override protected def getQueryBuilder: OqlBuilder[SyllabusExperiment] = {
    given project: Project = getProject

    val semester = entityDao.get(classOf[Semester], getInt("semester.id", 0))
    put("semester", semester)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    query.where(":date between experiment.syllabus.beginOn and experiment.syllabus.endOn", semester.beginOn.plusDays(30))
    queryByDepart(query, "experiment.syllabus.department")
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new SyllabusExperimentPropertyExtractor()
  }

  override def simpleEntityName: String = "experiment"
}
