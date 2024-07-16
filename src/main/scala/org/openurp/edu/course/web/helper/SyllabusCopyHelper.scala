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

import org.openurp.base.edu.model.{Course, CourseJournal}
import org.openurp.base.model.AuditStatus.Draft
import org.openurp.base.model.Semester
import org.openurp.edu.course.model.*

import java.time.Instant

/** FIXME
 * MOVE to edu core module
 */
object SyllabusCopyHelper {

  def copy(syllabus: Syllabus, semester: Semester, course: Course): Syllabus = {
    val newer = new Syllabus
    newer.semester = semester
    newer.beginOn = semester.beginOn
    newer.docLocale = syllabus.docLocale
    newer.status = Draft

    //copy course info
    newer.course = course
    val journal =
      course.journals.find(_.within(semester.beginOn)) match
        case None => new CourseJournal(course, semester.beginOn)
        case Some(j) => j
    newer.department = journal.department
    newer.creditHours = journal.creditHours
    syllabus.hours foreach { h =>
      val nh = new SyllabusCreditHour(newer, h.nature, h.creditHours, h.weeks)
      newer.hours.addOne(nh)
    }
    newer.learningHours = syllabus.learningHours
    newer.examCreditHours = syllabus.examCreditHours
    syllabus.examHours foreach { eh =>
      val neh = new SyllabusExamHour(newer, eh.nature, eh.creditHours)
      newer.examHours.addOne(neh)
    }

    //copy syllabus basis info
    newer.rank = syllabus.rank
    newer.module = syllabus.module
    newer.stage = syllabus.stage
    newer.nature = syllabus.nature
    newer.examMode = syllabus.examMode
    newer.gradingMode = syllabus.gradingMode
    newer.methods = syllabus.methods
    newer.description = syllabus.description
    newer.subsequents = syllabus.subsequents
    newer.prerequisites = syllabus.prerequisites
    newer.levels.addAll(syllabus.levels)
    newer.majors.addAll(syllabus.majors)

    //copy objectives
    syllabus.objectives foreach { obj =>
      val nobj = new SyllabusObjective(newer, obj.code, obj.name, obj.contents)
      newer.objectives.addOne(nobj)
    }
    //copy outcomes
    syllabus.outcomes foreach { oc =>
      val noc = new SyllabusOutcome(newer, oc.idx, oc.title, oc.contents, oc.courseObjectives)
      newer.outcomes.addOne(noc)
    }
    //copy topics
    syllabus.topics foreach { topic =>
      val nt = new SyllabusTopic
      nt.idx = topic.idx
      nt.exam = topic.exam
      nt.name = topic.name
      nt.contents = topic.contents
      nt.learningHours = topic.learningHours
      nt.methods = topic.methods
      nt.objectives = topic.objectives
      topic.elements foreach { ele =>
        val ne = new SyllabusTopicElement(nt, ele.label, ele.contents)
        nt.elements.addOne(ne)
      }
      topic.hours foreach { h =>
        val nh = new SyllabusTopicHour(nt, h.nature, h.creditHours)
        nt.hours.addOne(nh)
      }
      nt.syllabus = newer
      newer.topics.addOne(nt)
    }

    // copy designs
    syllabus.designs foreach { design =>
      val nd = new SyllabusMethodDesign
      nd.idx = design.idx
      nd.name = design.name
      nd.contents = design.contents
      nd.hasExperiment = design.hasExperiment
      nd.hasCase = design.hasCase
      nd.syllabus = newer
      newer.designs.addOne(nd)
    }
    syllabus.cases foreach { c =>
      val nc = new SyllabusCase(newer, c.idx, c.name)
      newer.cases.addOne(nc)
    }
    syllabus.experiments foreach { e =>
      val ne = new SyllabusExperiment(newer, e.idx, e.name, e.creditHours, e.experimentType, e.online)
      newer.experiments.addOne(ne)
    }
    //copy assessment
    syllabus.assessments foreach { a =>
      val na = new SyllabusAssessment(newer, a.gradeType, a.component)
      na.idx = a.idx
      na.description = a.description
      na.scorePercent = a.scorePercent
      na.scoreTable = a.scoreTable
      na.assessCount = a.assessCount
      na.objectivePercents = a.objectivePercents
      newer.assessments.addOne(na)
    }
    syllabus.texts foreach { t =>
      val nt = new SyllabusText(newer, t.indexno, t.name, t.contents)
      newer.texts.addOne(nt)
    }
    //copy resources
    newer.materials = syllabus.materials
    newer.bibliography = syllabus.bibliography
    newer.website = syllabus.website
    newer.textbooks.addAll(syllabus.textbooks)
    newer.updatedAt = Instant.now
    newer
  }
}
