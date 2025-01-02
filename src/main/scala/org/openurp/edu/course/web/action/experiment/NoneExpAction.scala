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

import org.beangle.commons.text.inflector.en.EnNounPluralizer
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.{EntityAction, ExportSupport}
import org.openurp.base.model.{Project, Semester}
import org.openurp.code.edu.model.TeachingNature
import org.openurp.edu.course.model.Syllabus
import org.openurp.edu.course.web.helper.SyllabusPropertyExtractor
import org.openurp.starter.web.support.ProjectSupport

class NoneExpAction extends ActionSupport, EntityAction[Syllabus], ProjectSupport, ExportSupport[Syllabus] {
  var entityDao: EntityDao = _

  def index(): View = {
    given project: Project = getProject

    val departs = getDeparts
    put("departs", departs)
    put("project", project)
    put("semester", getSemester)
    forward()
  }

  def search(): View = {
    put(EnNounPluralizer.pluralize(simpleEntityName), entityDao.search(getQueryBuilder))
    forward()
  }

  override def getQueryBuilder: OqlBuilder[Syllabus] = {
    given project: Project = getProject

    val semester = entityDao.get(classOf[Semester], getInt("semester.id", 0))
    put("semester", semester)
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    val query = super.getQueryBuilder
    query.where(":date between syllabus.beginOn and syllabus.endOn", semester.beginOn.plusDays(30))
    query.where("size(syllabus.experiments)=0")
    queryByDepart(query, "syllabus.department")
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new SyllabusPropertyExtractor()
  }

}
