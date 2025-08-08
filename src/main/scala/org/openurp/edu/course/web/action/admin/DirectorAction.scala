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

package org.openurp.edu.course.web.action.admin

import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Course, CourseDirector, TeachingOffice}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Department, Project}
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.CourseTask
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate

class DirectorAction extends RestfulAction[CourseDirector], ProjectSupport {

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("teachingOffices", getOffices(project, departs))
    put("departments", departs)
    put("semester", getSemester)
    put("project", project)
    forward()
  }

  private def getOffices(project: Project, departs: Seq[Department]): Seq[TeachingOffice] = {
    val query = OqlBuilder.from(classOf[TeachingOffice], "o")
    query.where("o.project=:project", project)
    query.where("o.department in(:departs)", departs)
    query.orderBy("o.name")
    entityDao.search(query)
  }

  override protected def getQueryBuilder: OqlBuilder[CourseDirector] = {
    given project: Project = getProject

    val query = super.getQueryBuilder
    query.where("director.course.project=:project", project)
    queryByDepart(query, "director.course.department")
    getBoolean("assigned").foreach {
      case true => query.where("director.director is not null")
      case false => query.where("director.director is null")
    }
    getInt("semester.id") foreach { semesterId =>
      query.where(s"exists(from ${classOf[Clazz].getName} clz where clz.course=director.course and clz.semester.id=:semesterId)", semesterId)
    }
    query
  }

  override protected def editSetting(entity: CourseDirector): Unit = {
    given project: Project = getProject

    put("project", project)
    put("offices", getOffices(project, Seq(entity.course.department)))
    super.editSetting(entity)
  }

  override protected def saveAndRedirect(director: CourseDirector): View = {
    val directorId = getLong("director.id")
    directorId foreach { id =>
      director.director = entityDao.get(classOf[Teacher], id)
    }
    super.saveAndRedirect(director)
  }

  def autoImport(): View = {
    val project = getProject
    val query = OqlBuilder.from(classOf[Course], "course")
    query.where("course.project=:project", project)
    queryByDepart(query, "course.department")
    query.where("course.endOn is null or course.endOn >:today", LocalDate.now)
    query.where(s"not exists(from ${classOf[CourseDirector].getName} cd where cd.course=course)")
    val courses = entityDao.search(query)
    val directors = courses.map(x => new CourseDirector(x))
    entityDao.saveOrUpdate(directors)
    redirect("search", "自动导入成功")
  }

  def batchEdit(): View = {
    val directors = entityDao.find(classOf[CourseDirector], getLongIds("director"))
    val project = getProject
    put("offices", getOffices(project, directors.map(_.course.department).distinct))
    put("directors", directors)
    put("project", project)
    forward()
  }

  def batchSave(): View = {
    val directors = entityDao.find(classOf[CourseDirector], getLongIds("director"))
    val directorId = getLong("teacher.id")
    directorId foreach { id =>
      val t = entityDao.get(classOf[Teacher], id)
      directors foreach (_.director = t)
    }
    val officeId = getLong("office.id")
    officeId match {
      case None => directors foreach (_.office = None)
      case Some(id) =>
        val t = entityDao.get(classOf[TeachingOffice], id)
        directors foreach (_.office = Some(t))
    }
    entityDao.saveOrUpdate(directors)
    redirect("search", "批量成功")
  }

  /** 自动学习指定负责人和教研室
   *
   * @return
   */
  def autoAssisgn(): View = {
    val directors = entityDao.find(classOf[CourseDirector], getLongIds("director"))
    directors foreach { director =>
      val q = OqlBuilder.from(classOf[CourseTask], "task")
      q.where("task.course=:course", director.course)
      q.where("task.director is not null")
      q.orderBy("task.semester.beginOn desc")
      entityDao.first(q) foreach { last =>
        last.director foreach { d =>
          director.director = d
        }
        last.office foreach { o =>
          director.office = Some(o)
        }
      }
      entityDao.saveOrUpdate(director)
    }
    redirect("search", "批量设置成功")
  }

  override protected def simpleEntityName: String = "director"

}
