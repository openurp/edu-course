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

package org.openurp.edu.course.web.action.syllabus

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.web.action.annotation.mapping
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, Textbook}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{CalendarStage, Project, Semester, User}
import org.openurp.code.edu.model.*
import org.openurp.edu.course.model.*
import org.openurp.starter.web.support.TeacherSupport

import java.time.Instant
import java.util.Locale

/**
 * 教师修订教学大纲
 */
class ReviseAction extends TeacherSupport, EntityAction[Syllabus] {

  protected override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val q = OqlBuilder.from(classOf[CourseTask], "c")
    q.where("c.course.project=:project", project)
    q.where("c.director=:me", teacher)
    val courses = entityDao.search(q).map(_.course)
    put("courses", courses)
    forward()
  }

  def edit(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    put("course", syllabus.course)
    put("syllabus", syllabus)
    putBasicDatas(syllabus.course)

    given project: Project = syllabus.course.project

    //topic item
    put("topicLabels", getCodes(classOf[SyllabusTopicLabel]))

    //textbook item
    if (get("step").contains("textbook")) {
      put("textbooks", entityDao.getAll(classOf[Textbook]))
    }
    if (get("step").contains("outcomes")) {
      put("graduateObjectives", entityDao.getAll(classOf[GraduateObjective]))
    }
    val locale = syllabus.locale
    get("step") match
      case None => forward(s"${locale}/form")
      case Some(s) => forward(s"${locale}/${s}")
  }

  private def putBasicDatas(course: Course): Unit = {
    given project: Project = course.project

    put("project", project)
    put("departments", List(course.department))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("teachingMethods", getCodes(classOf[TeachingMethod]))
    put("courseNatures", getCodes(classOf[CourseNature]))
    put("examModes", getCodes(classOf[ExamMode]))
    put("gradingModes", getCodes(classOf[GradingMode]))
    put("courseModules", getCodes(classOf[CourseModule]))
    put("courseRanks", getCodes(classOf[CourseRank]))
    put("experimentTypes", getCodes(classOf[ExperimentType]))

    val s = OqlBuilder.from(classOf[CalendarStage], "s")
    s.where("s.school=:school and s.vacation=false", project.school)
    s.orderBy("s.startWeek").cacheable()
    put("calendarStages", entityDao.search(s))

    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
  }

  @mapping(value = "new", view = "new,form")
  def editNew(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))

    given project: Project = course.project

    putBasicDatas(course)
    val syllabus = newSyllabus(course)
    syllabus.semester = getSemester
    put("course", course)
    put("syllabus", syllabus)
    val locale = get("locale", classOf[Locale]).getOrElse(Locale.SIMPLIFIED_CHINESE)
    put("locale", locale)

    get("step") match
      case None => forward(s"${locale}/form")
      case Some(s) => forward(s"${locale}/${s}")
  }

  private def newSyllabus(course: Course): Syllabus = {
    val syllabus = new Syllabus
    syllabus.course = course
    syllabus.department = course.department
    syllabus.examMode = course.examMode
    syllabus.gradingMode = course.gradingMode
    syllabus
  }

  def save(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))

    given project: Project = course.project

    val me = entityDao.findBy(classOf[User], "code", Securities.user).head
    val syllabus = populateEntity()
    if (!syllabus.persisted) {
      syllabus.beginOn = entityDao.get(classOf[Semester], syllabus.semester.id).beginOn
      syllabus.course = course
    }
    if (null == syllabus.description) {
      syllabus.description = "--"
    }
    val methods = entityDao.find(classOf[TeachingMethod], getIntIds("teachingMethod"))
    syllabus.methods.clear()
    syllabus.methods.addAll(methods)
    populateHours(syllabus)
    syllabus.writer = me
    syllabus.updatedAt = Instant.now
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  private def populateHours(syllabus: Syllabus)(using project: Project): Unit = {
    val teachingNatures = getCodes(classOf[TeachingNature])
    teachingNatures foreach { ht =>
      val creditHour = getInt("creditHour" + ht.id)
      val week = getInt("week" + ht.id)
      syllabus.hours find (h => h.nature == ht) match {
        case Some(hour) =>
          if (week.isEmpty && creditHour.isEmpty) {
            syllabus.hours -= hour
          } else {
            hour.weeks = week.getOrElse(0)
            hour.creditHours = creditHour.getOrElse(0)
          }
        case None =>
          if (!(week.isEmpty && creditHour.isEmpty)) {
            syllabus.hours += new SyllabusCreditHour(syllabus, ht, creditHour.getOrElse(0), week.getOrElse(0))
          }
      }
    }
  }

  def saveObjectives(): View = {
    val syllabus = populateEntity()
    syllabus.updatedAt = Instant.now
    syllabus.getText("values") match
      case Some(values) => values.contents = get("values", "--")
      case None =>
        val v = new SyllabusText(syllabus, "2", "values", get("values", "--"))
        syllabus.texts.addOne(v)

    (1 to 8) foreach { i =>
      val code = s"CO${i}"
      val contents = get(code, "")
      syllabus.getObjective(code) match {
        case None =>
          if Strings.isNotBlank(contents) then
            val o = new SyllabusObjective(syllabus, code, code, contents)
            syllabus.objectives += o
        case Some(o) =>
          if Strings.isBlank(contents) then
            syllabus.objectives -= o
          else
            o.contents = contents
      }
    }
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  def saveOutcomes(): View = {
    val syllabus = populateEntity()
    syllabus.updatedAt = Instant.now

    given project: Project = getProject

    val gos = getCodes(classOf[GraduateObjective])
    gos foreach { go =>
      val name = s"GO${go.id}"
      val cos = Strings.split(get(name + ".courseObjectives", "")).toSeq.sorted.mkString(",")
      val contents = get(name + ".contents", "")
      syllabus.getOutcome(go) match
        case None =>
          if Strings.isNotBlank(contents) then
            val o = new SyllabusOutcome(syllabus, go, contents, cos)
            syllabus.outcomes += o
        case Some(o) =>
          if Strings.isBlank(contents) then
            syllabus.outcomes -= o
          else
            o.courseObjectives = cos
            o.contents = contents
    }
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  def editTopic(): View = {
    val topic = entityDao.get(classOf[SyllabusTopic], getLongId("topic"))

    given project: Project = topic.syllabus.course.project

    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("teachingMethods", getCodes(classOf[TeachingMethod]))
    put("topicLabels", getCodes(classOf[SyllabusTopicLabel]))
    put("topic", topic)
    put("syllabus", topic.syllabus)

    forward(s"${topic.syllabus.locale}/editTopic")
  }

  /** 保存主题
   *
   * @return
   */
  def saveTopic(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))

    given project: Project = syllabus.course.project

    val topic = populateEntity(classOf[SyllabusTopic], "topic")
    if (!topic.persisted) {
      topic.syllabus = syllabus
      syllabus.topics += topic
    }
    getCodes(classOf[SyllabusTopicLabel]) foreach { label =>
      val elm = get(s"element${label.id}", "")
      topic.getElement(label) match
        case None =>
          if Strings.isNotBlank(elm) then
            topic.elements += new SyllabusTopicElement(topic, label, elm)
        case Some(e) =>
          if Strings.isBlank(elm) then
            topic.elements -= e
          else
            e.contents = elm
    }
    val methods = entityDao.find(classOf[TeachingMethod], getIntIds("teachingMethod"))
    topic.methods.clear()
    topic.methods.addAll(methods)

    val teachingNatures = getCodes(classOf[TeachingNature])
    teachingNatures foreach { ht =>
      val creditHour = getInt("creditHour" + ht.id)
      val week = getInt("week" + ht.id)
      topic.hours find (h => h.nature == ht) match {
        case Some(hour) =>
          if (week.isEmpty && creditHour.isEmpty) {
            topic.hours -= hour
          } else {
            hour.weeks = week.getOrElse(0)
            hour.creditHours = creditHour.getOrElse(0)
          }
        case None =>
          if (!(week.isEmpty && creditHour.isEmpty)) {
            topic.hours += new SyllabusTopicHour(topic, ht, creditHour.getOrElse(0), week.getOrElse(0))
          }
      }
    }
    val objectives = entityDao.find(classOf[SyllabusObjective], getLongIds("objective"))
    topic.objectives = None
    if (objectives.nonEmpty) {
      topic.objectives = Some(objectives.map(_.code).mkString(","))
    }
    syllabus.updatedAt = Instant.now
    entityDao.saveOrUpdate(syllabus, topic)
    redirect("edit", s"syllabus.id=${syllabus.id}&step=topics", "info.save.success")
  }

  def removeTopic(): View = {
    val topic = entityDao.get(classOf[SyllabusTopic], getLongId("topic"))
    val syllabus = topic.syllabus
    syllabus.topics -= topic
    syllabus.updatedAt = Instant.now
    entityDao.saveOrUpdate(syllabus)
    redirect("edit", s"syllabus.id=${syllabus.id}&step=topics", "info.save.success")
  }

  @deprecated
  def topicInfo(): View = {
    val topic = entityDao.get(classOf[SyllabusTopic], getLongId("topic"))
    put("topic", topic)
    forward(s"${topic.syllabus.locale}/topicInfo")
  }

  def editDesign(): View = {
    val design = entityDao.get(classOf[SyllabusMethodDesign], getLongId("design"))
    put("design", design)
    put("syllabus", design.syllabus)

    given project: Project = design.syllabus.course.project

    put("experimentTypes", getCodes(classOf[ExperimentType]))
    forward(s"${design.syllabus.locale}/editDesign")
  }

  def saveDesign(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    syllabus.updatedAt = Instant.now()
    val design = populateEntity(classOf[SyllabusMethodDesign], "design")
    if (!design.persisted) {
      design.syllabus = syllabus
      syllabus.designs += design
    }
    val caseAndExps = getAll("caseAndExperiments", classOf[String]).toSet
    if (caseAndExps.contains("hasCase")) {
      val cases = syllabus.cases.map(x => (x.idx, x)).toMap
      (0 to 9) foreach { i =>
        val name = get(s"case${i}.name", "")
        cases.get(i) match
          case None =>
            if (Strings.isNotBlank(name)) {
              syllabus.cases += new SyllabusCase(syllabus, i, name)
            }
          case Some(c) =>
            if Strings.isBlank(name) then syllabus.cases -= c else c.name = name
      }
      design.hasCase = true
    } else {
      design.hasCase = false
    }
    if (caseAndExps.contains("hasExperiment")) {
      val experiments = syllabus.experiments.map(x => (x.idx, x)).toMap
      (0 to 9) foreach { i =>
        val name = get(s"experiment${i}.name", "")
        experiments.get(i) match
          case None =>
            if (Strings.isNotBlank(name)) {
              val experimentType = entityDao.get(classOf[ExperimentType], getInt(s"experiment${i}.experimentType.id", 0))
              val online = getBoolean(s"experiment${i}.online", false)
              syllabus.experiments += new SyllabusExperiment(syllabus, i, name, experimentType, online)
            }
          case Some(c) =>
            if Strings.isBlank(name) then syllabus.experiments -= c else c.name = name
      }
      design.hasExperiment = true
    } else {
      design.hasExperiment = false
    }
    if (!syllabus.designs.exists(_.hasCase)) {
      syllabus.cases.clear()
    }
    if (!syllabus.designs.exists(_.hasExperiment)) {
      syllabus.experiments.clear()
    }

    entityDao.saveOrUpdate(syllabus)
    redirect("edit", s"syllabus.id=${syllabus.id}&step=designs", "info.save.success")
  }

  def removeDesign(): View = {
    val design = entityDao.get(classOf[SyllabusMethodDesign], getLongId("design"))
    val syllabus = design.syllabus
    syllabus.designs -= design
    syllabus.updatedAt = Instant.now
    entityDao.saveOrUpdate(syllabus)
    redirect("edit", s"syllabus.id=${syllabus.id}&step=designs", "info.save.success")
  }

  def assesses(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))

    given project: Project = syllabus.course.project

    put("usualType", entityDao.get(classOf[GradeType], GradeType.Usual))
    put("endType", entityDao.get(classOf[GradeType], GradeType.End))
    put("syllabus", syllabus)
    forward(s"${syllabus.locale}/assesses")
  }

  def saveAssess(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    syllabus.updatedAt = Instant.now()
    val usualType = entityDao.get(classOf[GradeType], GradeType.Usual)
    val endType = entityDao.get(classOf[GradeType], GradeType.End)
    popluateAssessment(syllabus, endType, 0, None)
    popluateAssessment(syllabus, usualType, 0, None)

    (0 to 4) foreach { i =>
      val component = get(s"grade${usualType.id}_${i}.component", "")
      val percent = getInt(s"grade${usualType.id}_${i}.scorePercent", 0)
      if (percent > 0 && Strings.isNotBlank(component)) {
        popluateAssessment(syllabus, usualType, i, Some(component))
      }
    }
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  def removeAssess(): View = {
    val assessment = entityDao.get(classOf[SyllabusAssessment], getLongId("assessment"))
    val syllabus = assessment.syllabus
    syllabus.assessments -= assessment
    entityDao.saveOrUpdate(syllabus)
    redirect("assesses", s"syllabus.id=${syllabus.id}", "info.remove.success")
  }

  /** 将评价标准移动到指定位置
   *
   * @return
   */
  def moveAssess(): View = {
    val assessment = entityDao.get(classOf[SyllabusAssessment], getLongId("assessment"))
    val syllabus = assessment.syllabus
    val idx = getInt("idx", 1) - 1
    assessment.idx = idx
    syllabus.assessments foreach { a =>
      if (a.component.nonEmpty) {
        if (a.idx >= idx && a != assessment) {
          a.idx += 1
        }
      }
    }
    entityDao.saveOrUpdate(syllabus)
    redirect("assesses", s"syllabus.id=${syllabus.id}", "info.save.success")
  }

  private def popluateAssessment(syllabus: Syllabus, gradeType: GradeType, index: Int, componentName: Option[String]): SyllabusAssessment = {
    val assessment = syllabus.getAssessment(gradeType, componentName.orNull).getOrElse(new SyllabusAssessment(syllabus, gradeType, componentName))
    if (!assessment.persisted) {
      syllabus.assessments += assessment
    }
    assessment.idx = index
    val prefix = componentName match
      case None => "grade" + gradeType.id
      case Some(n) => "grade" + gradeType.id + "_" + index
    populate(assessment, prefix)
    val percents = Collections.newMap[String, Int]
    syllabus.objectives foreach { co =>
      val p = getInt(s"usual_${index}_co${co.id}", 0)
      if p > 0 then percents.put(co.code, p)
    }
    assessment.updateObjectivePercents(percents.toMap)

    assessment.component foreach { n =>
      var name = Strings.replace(n, "\r", "")
      name = Strings.replace(n, "\n", "")
      name = Strings.replace(n, " ", "")
      assessment.component = Some(name)
    }
    //    assessment.scoreTable foreach { table =>
    //      assessment.scoreTable = Some(HtmlTableHelper.cleanup(table))
    //    }
    assessment
  }

  def saveTextbook(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    syllabus.updatedAt = Instant.now()
    syllabus.textbooks.clear()
    syllabus.textbooks ++= entityDao.find(classOf[Textbook], getLongIds("textbook"))
    syllabus.materials = get("syllabus.materials")
    syllabus.bibliography = get("syllabus.bibliography")
    syllabus.website = get("syllabus.website")
    entityDao.saveOrUpdate(syllabus)
    redirect("info", s"&syllabus.id=${syllabus.id}", "info.save.success")
  }

  private def toStep(syllabus: Syllabus): View = {
    get("step") match
      case None => redirect("info", "info.save.success")
      case Some(s) => redirect("edit", s"syllabus.id=${syllabus.id}&step=${s}", "info.save.success")
  }

  def nextStep(): View = {
    redirect("edit", s"syllabus.id=${getLongId("syllabus")}&step=${get("step").get}", "info.save.success")
  }

  def course(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))
    put("course", course)

    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    val syllabuses = entityDao.findBy(classOf[Syllabus], "course", course)
    put("syllabuses", syllabuses)
    forward()
  }

  def info(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    put("syllabus", syllabus)
    put("usualType", entityDao.get(classOf[GradeType], GradeType.Usual))
    put("endType", entityDao.get(classOf[GradeType], GradeType.End))
    put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    forward(s"/org/openurp/edu/course/syllabus/${syllabus.course.project.school.id}/${syllabus.course.project.id}/report_${syllabus.locale}")
  }
}
