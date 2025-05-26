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

import org.beangle.commons.lang.Strings
import org.beangle.data.model.LongId
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.SyllabusObjective

/** 考试试卷得分
 */
class ExamQuestionGrade extends LongId {
  var clazz: Clazz = _
  var questionIdx: String = _
  var score: Float = _
  var avgScore: Float = _
  var objectives: String = _
  var stdScores: Option[String] = None

  def supportWith(syllabusObjective: SyllabusObjective): Boolean = {
    Strings.split(objectives).toSet.contains(syllabusObjective.code)
  }
}

object ExamQuestionGrade {
  def apply(question: String, score: Float, objectives: String, avgScore: Float): ExamQuestionGrade = {
    val grade = new ExamQuestionGrade()
    grade.questionIdx = question
    grade.score = score
    grade.objectives = objectives
    grade.avgScore = avgScore
    grade
  }
}
