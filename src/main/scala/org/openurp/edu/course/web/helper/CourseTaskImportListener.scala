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

package org.openurp.edu.course.web.helper

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.transfer.importer.{ImportListener, ImportResult}
import org.openurp.base.edu.model.CourseDirector
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Department, Project, Semester}
import org.openurp.edu.course.model.CourseTask

class CourseTaskImportListener(entityDao: EntityDao, semester: Semester, project: Project) extends ImportListener {
  override def onItemStart(tr: ImportResult): Unit = {
    var task: CourseTask = null
    transfer.curData.get("course.code") foreach { code =>
      val query = OqlBuilder.from(classOf[CourseTask], "ct")
      query.where("ct.semester=:semester", semester)
      query.where("ct.course.code =:code and ct.course.project=:project", code, project)
      val cs = entityDao.search(query)
      if (cs.nonEmpty) {
        transfer.current = cs.head
        task = cs.head
      }
      else tr.addFailure("课程修订任务不存在", code)
    }
    var depart: Department = null
    transfer.curData.get("department.code") foreach { c =>
      var code = c.toString
      if (code.contains(" ")) {
        code = Strings.substringBefore(code, " ")
      }
      val query = OqlBuilder.from(classOf[Department], "d")
      query.where("(d.code=:code or d.name=:name) and d.school=:school", code, code, project.school)
      val departs = entityDao.search(query)
      if (departs.size == 1) {
        depart = departs.head
        transfer.curData.put("courseTask.department", departs.head)
      } else {
        tr.addFailure("部门代码/名称不唯一", code)
      }
    }

    transfer.curData.get("teacher.code") foreach { c =>
      var code = c.toString
      if (code.contains(" ")) {
        code = Strings.substringBefore(code, " ")
      }
      if (null != task) {
        task.teachers.find(x => x.code == code || x.name == code) match
          case None =>
            val query = OqlBuilder.from(classOf[Teacher], "t")
            query.where("(t.staff.code=:code or t.staff.name=:name) and t.staff.school=:school", code, code, project.school)
            var teachers = entityDao.search(query)
            if (teachers.size == 1) {
              transfer.curData.put("courseTask.director", teachers.head)
            } else {
              if (null != depart) {
                query.where("t.department=:depart", depart)
                teachers = entityDao.search(query)
                if (teachers.size == 1) {
                  transfer.curData.put("courseTask.director", teachers.head)
                } else {
                  tr.addFailure("教师姓名不唯一", code)
                }
              } else {
                tr.addFailure("教师姓名不唯一", code)
              }
            }
          case Some(t) =>
            transfer.curData.put("courseTask.director", t)
      }
    }
  }

  override def onItemFinish(tr: ImportResult): Unit = {
    val task = transfer.current.asInstanceOf[CourseTask]
    if (task.course != null) {
      if (task.courseType == null) task.courseType = task.course.courseType.orNull
      if (null == task.semester) task.semester = semester
      if (task.director.nonEmpty) {
        val directors = entityDao.findBy(classOf[CourseDirector], "course", task.course).find(_.within(semester.beginOn))
        val cd = directors match {
          case Some(d) => d
          case None =>
            val ncd = new CourseDirector(task.course)
            ncd.beginOn = semester.beginOn
            ncd
        }
        if (task.office.nonEmpty) cd.office = task.office
        cd.director = task.director.get
        entityDao.saveOrUpdate(task, cd)
      } else {
        entityDao.saveOrUpdate(task)
      }
    }
  }
}
