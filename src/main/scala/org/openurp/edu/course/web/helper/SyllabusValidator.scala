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

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.openurp.code.edu.model.{GradeType, TeachingNature}
import org.openurp.edu.course.model.Syllabus

import java.util.Locale

object SyllabusValidator {

  def validate(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    if (syllabus.creditHours > 0 && syllabus.topics.isEmpty) {
      messages += "缺少课程主题"
    }
    if (syllabus.designs.isEmpty) {
      messages += "缺少教学设计"
    }
    messages ++= validateRequirements(syllabus)
    messages ++= validateObjectives(syllabus)
    messages ++= validateHours(syllabus)
    messages ++= validAssessment(syllabus)
    messages.toSeq
  }

  def validateRequirements(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    syllabus.outcomes foreach { o =>
      if (Strings.isBlank(o.contents)) {
        messages.addOne(s"毕业要求【${o.title}】缺少内容")
      }
      val max = if syllabus.docLocale == Locale.SIMPLIFIED_CHINESE then 30 else 150
      if (o.title.length > max) {
        messages.addOne(s"毕业要求[${o.idx}]的标题过长：【${o.title}】")
      }
    }
    messages.toSeq
  }

  /** 验证考核比例
   *
   * @param syllabus
   * @return
   */
  def validAssessment(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    val usualType = new GradeType(GradeType.Usual)
    val endType = new GradeType(GradeType.End)
    val endAssessment = syllabus.getAssessment(endType, null)
    val usualPercent = syllabus.getAssessment(usualType, null).map(_.scorePercent).getOrElse(0)
    val endPercent = endAssessment.map(_.scorePercent).getOrElse(0)
    if (usualPercent + endPercent != 100) {
      messages.addOne(s"平时期末百分比合计为${usualPercent + endPercent}，应等于100.")
    }
    endAssessment foreach { a =>
      if (a.scorePercent > 0) {
        val s = a.objectivePercentMap.values.sum
        if (s != 100) {
          messages.addOne(s"期末成绩对课程目标的占比合计为${s}，应等于100.")
        }
      }
    }
    if (usualPercent > 0) {
      val usualAssessments = syllabus.assessments.filter(x => x.gradeType.id == GradeType.Usual && x.component.nonEmpty)
      val usualTotal = usualAssessments.map(_.scorePercent).sum
      if (usualTotal != 100) {
        messages.addOne(s"平时成绩，各个环节合计占比为${usualTotal}，应等于100.")
      }
      usualAssessments foreach { a =>
        val s = a.objectivePercentMap.values.sum
        if (s != a.scorePercent) {
          messages.addOne(s"平时成绩--${a.component.get}的课程目标的占比合计为${s}，应等于${a.scorePercent}.")
        }
      }
    }
    messages.toSeq
  }

  def validateObjectives(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    syllabus.topics foreach { topic =>
      if (!topic.exam) {
        if (topic.objectives.isEmpty || Strings.isBlank(topic.objectives.get)) {
          messages += s"教学主题:${topic.name} 缺少课程目标"
        }
      }
    }
    syllabus.objectives foreach { o =>
      if (!syllabus.outcomes.exists(_.supportWith(o))) {
        messages += s"课程目标${o.name} 没有支撑任何毕业要求"
      }
      if (!syllabus.topics.exists(x => x.objectives.exists { j => Strings.split(j).toSeq.contains(o.name) })) {
        messages += s"课程目标${o.name} 没有体现在教学主题中"
      }
    }
    val errorObjectives = Collections.newBuffer[String]
    syllabus.outcomes foreach { o =>
      Strings.split(o.courseObjectives) foreach { obj =>
        if !syllabus.objectives.exists(_.name == obj) then
          errorObjectives.addOne(obj)
      }
    }
    if errorObjectives.nonEmpty then
      messages += s"毕业要求支撑矩阵中出现了错误的课程目标:${errorObjectives.mkString(",")}"

    errorObjectives.clear()
    syllabus.topics foreach { topic =>
      topic.objectives foreach { objectives =>
        Strings.split(objectives) foreach { obj =>
          if !syllabus.objectives.exists(_.name == obj) then
            errorObjectives.addOne(obj)
        }
      }
    }
    if errorObjectives.nonEmpty then
      messages += s"教学主题中出现了错误的课程目标:${errorObjectives.mkString(",")}"

    messages.toSeq
  }

  def validateHours(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    var total = 0f
    syllabus.hours foreach { h =>
      total += h.creditHours
    }
    if java.lang.Double.compare(total.toDouble, syllabus.creditHours * 1.0) != 0 then
      messages += s"课程要求${syllabus.creditHours}学时，分项累计${total}学时，请检查。"

    syllabus.hours foreach { h =>
      var t = 0f
      syllabus.topics foreach { p =>
        t += p.getHour(h.nature).map(_.creditHours).getOrElse(0f)
      }
      if (java.lang.Double.compare(t, h.creditHours) != 0) {
        messages += s"课程要求${h.nature.name}${h.creditHours}学时，教学内容累计${t}学时，请检查。"
      }
    }
    var totalLearningHours = 0f
    syllabus.topics foreach { t =>
      totalLearningHours += t.learningHours
    }
    if (java.lang.Double.compare(totalLearningHours, syllabus.learningHours) != 0) {
      messages += s"自主学习要求${syllabus.learningHours}学时，教学内容累计${totalLearningHours}学时，请检查。"
    }

    syllabus.topics foreach { p =>
      val hours = p.hours.map(_.creditHours).sum
      if (hours == 0) {
        if(p.learningHours==0){
          if (p.hours.isEmpty) {
            messages += s"教学主题:${p.name},缺少学时分布"
          } else {
            messages += s"教学主题:${p.name},学时为0"
          }
        }
      }

      if (!p.exam && p.methods.isEmpty) {
        messages += s"教学主题:${p.name},缺少教学方法"
      }
    }
    //验证实验学时
    val totalExperimentHours = syllabus.experiments.map(_.creditHours).sum
    val totalPracticalHours = syllabus.hours.find(_.nature.id == TeachingNature.Practice).map(_.creditHours).getOrElse(0f)
    if (totalExperimentHours > totalPracticalHours) {
      messages += s"实验要求${totalExperimentHours}学时，超过了${totalPracticalHours}总的实践学时，请检查。"
    }
    messages.toSeq
  }

}
