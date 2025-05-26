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

package org.openurp.edu.course.web.action.assess

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Locales
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.support.helper.QueryHelper
import org.beangle.webmvc.view.View
import org.openurp.base.model.Project
import org.openurp.code.edu.model.GradeType
import org.openurp.edu.course.model.{CourseTask, Syllabus}
import org.openurp.starter.web.support.ProjectSupport

/** 课程目标达程度分析
 */
class CourseAction extends ActionSupport, ProjectSupport, EntityAction[CourseTask] {
  var entityDao: EntityDao = _

  def index(): View = {
    given project: Project = getProject

    val departs = getDeparts
    put("departments", departs)
    put("project", project)
    put("semester", getSemester)
    forward()
  }

  def search(): View = {
    val builder = OqlBuilder.from(classOf[CourseTask], "courseTask")
    populateConditions(builder)
    QueryHelper.sort(builder)
    builder.tailOrder("courseTask.id")
    builder.limit(getPageLimit)
    builder.where("courseTask.course.project=:project", getProject)
    queryByDepart(builder, "courseTask.department")
    put("courseTasks", entityDao.search(builder))
    forward()
  }

  def assess(): View = {
    val task = entityDao.get(classOf[CourseTask], getLongId("courseTask"))
    val q = OqlBuilder.from(classOf[Syllabus], "s")
    task.director.foreach { d =>
      q.where("s.course = :course and s.writer.code = :writer", task.course, d.code)
    }
    q.where("s.semester.endOn >= :beginOn and :endOn >= s.semester.beginOn", task.semester.beginOn, task.semester.endOn)
    val syllabuses = entityDao.search(q)
    put("task", task)
    if (syllabuses.size == 1) {
      put("usualType", entityDao.get(classOf[GradeType], GradeType.Usual))
      put("endType", entityDao.get(classOf[GradeType], GradeType.End))
      put("locales", Map(Locales.chinese -> "中文", Locales.us -> "English"))
      put("syllabus", syllabuses.head)
      val questionScores = Collections.newBuffer[ExamQuestionGrade]
      questionScores.addOne(ExamQuestionGrade("1.1", 1f, "CO2", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.2", 1f, "CO2", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.3", 1f, "CO2", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.4", 1f, "CO1", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.5", 1f, "CO1", 0.94f))
      questionScores.addOne(ExamQuestionGrade("1.6", 1f, "CO1", 0.96f))
      questionScores.addOne(ExamQuestionGrade("1.7", 1f, "CO1", 0.97f))
      questionScores.addOne(ExamQuestionGrade("1.8", 1f, "CO2", 0.8f))
      questionScores.addOne(ExamQuestionGrade("1.9", 1f, "CO2", 0.7f))
      questionScores.addOne(ExamQuestionGrade("1.10", 1f, "CO2", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.11", 1f, "CO3", 0.3f))
      questionScores.addOne(ExamQuestionGrade("1.12", 1f, "CO3", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.13", 1f, "CO3", 0.9f))
      questionScores.addOne(ExamQuestionGrade("1.14", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.15", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.16", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.17", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.18", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.19", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("1.20", 1f, "CO3", 1f))
      questionScores.addOne(ExamQuestionGrade("2.1", 10f, "CO3", 10f))
      questionScores.addOne(ExamQuestionGrade("2.2", 10f, "CO3", 9.5f))
      questionScores.addOne(ExamQuestionGrade("3.1", 10f, "CO3", 7f))
      questionScores.addOne(ExamQuestionGrade("3.2", 10f, "CO3", 8f))
      questionScores.addOne(ExamQuestionGrade("4.1", 10f, "CO3", 9f))
      questionScores.addOne(ExamQuestionGrade("4.2", 10f, "CO3", 9f))
      questionScores.addOne(ExamQuestionGrade("5", 20f, "CO4", 18f))
      put("questionScores", questionScores)
      forward()
    } else {
      addError("找不到唯一的课程大纲，无法分析达成度")
      forward("error")
    }
  }
}
