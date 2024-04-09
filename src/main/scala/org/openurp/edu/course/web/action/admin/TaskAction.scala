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

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{CourseDirector, TeachingOffice}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Department, Project, Semester}
import org.openurp.edu.course.model.CourseTask
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.starter.web.support.ProjectSupport

/** 课程任务
 */
class TaskAction extends RestfulAction[CourseTask], ProjectSupport {

  var courseTaskService: CourseTaskService = _

  override protected def indexSetting(): Unit = {
    super.indexSetting()

    given project: Project = getProject

    val departs = getDeparts
    put("departments", departs)
    put("project", project)
    put("semester", getSemester)
    put("offices", getOffices(project, departs))
    forward()
  }

  override protected def getQueryBuilder: OqlBuilder[CourseTask] = {
    val query = super.getQueryBuilder
    query.where("courseTask.course.project=:project", getProject)
    queryByDepart(query, "courseTask.department")
    get("teachers").foreach {
      case "2" => query.where("size(courseTask.teachers) > 1")
      case "1" => query.where("size(courseTask.teachers) = 1")
      case "0" => query.where("size(courseTask.teachers) = 0")
      case _ =>
    }
    getBoolean("assigned").foreach {
      case true => query.where("courseTask.director is not null")
      case false => query.where("courseTask.director is null")
    }
    val teacherName = get("teacherName").orNull
    if (Strings.isNotBlank(teacherName)) {
      query.where("exists(from courseTask.teachers t where t.name like :name)", s"%$teacherName%")
    }
    getLong("office.id") foreach { officeId =>
      query.where(s"exists(from ${classOf[CourseDirector].getName} cd where cd.course=courseTask.course and cd.office.id=:officeId)", officeId)
    }
    query
  }

  override protected def editSetting(task: CourseTask): Unit = {
    given project: Project = getProject

    put("project", project)

    val departs = getDeparts
    put("departments", departs)
    //课程负责人和上课老师作为该学期负责人的候选人
    val director = entityDao.findBy(classOf[CourseDirector], "course", task.course).headOption
    put("director", director)
    val directors = Collections.newBuffer[Teacher]
    directors ++= task.teachers
    for (d <- director; t <- d.director) {
      if !directors.contains(t) then directors += t
    }

    put("directors", directors)
    super.editSetting(task)
  }

  def autoCreate(): View = {
    given project: Project = getProject

    val semester = entityDao.get(classOf[Semester], getIntId("courseTask.semester"))
    courseTaskService.statTask(project, semester)
    redirect("search", "自动建组成功")
  }

  def autoAssign(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    tasks foreach { t =>
      if (t.director.isEmpty) {
        if (t.teachers.size == 1) {
          t.director = t.teachers.headOption
        } else {
          entityDao.findBy(classOf[CourseDirector], "course", t.course).foreach { d =>
            d.director foreach { dd =>
              if t.teachers.contains(dd) then t.director = Some(dd)
            }
          }
        }
      }
    }
    entityDao.saveOrUpdate(tasks)
    redirect("search", "自动指派成功")
  }

  def batchEdit(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    put("courseTasks", tasks)
    put("project", getProject)
    forward()
  }

  def batchSave(): View = {
    val tasks = entityDao.find(classOf[CourseTask], getLongIds("courseTask"))
    val directorId = getLong("teacher.id")
    directorId match {
      case None => tasks foreach (_.director = None)
      case Some(id) =>
        val t = entityDao.get(classOf[Teacher], id)
        tasks foreach (_.director = Some(t))
    }
    entityDao.saveOrUpdate(tasks)
    redirect("search", "批量成功")
  }

  private def getOffices(project: Project, departs: Seq[Department]): Seq[TeachingOffice] = {
    val query = OqlBuilder.from(classOf[TeachingOffice], "o")
    query.where("o.project=:project", project)
    query.where("o.department in(:departs)", departs)
    query.orderBy("o.name")
    entityDao.search(query)
  }
}
