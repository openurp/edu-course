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
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.web.action.annotation.mapping
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, CourseProfile, Major, Textbook}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.*
import org.openurp.base.model.AuditStatus.Submited
import org.openurp.code.edu.model.*
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.*
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.SyllabusHelper
import org.openurp.edu.schedule.service.LessonSchedule
import org.openurp.edu.textbook.model.ClazzMaterial
import org.openurp.starter.web.support.TeacherSupport

import java.time.Instant
import java.util.Locale

/**
 * 教师修订教学大纲
 */
class ReviseAction extends TeacherSupport, EntityAction[Syllabus] {

  var businessLogger: WebBusinessLogger = _

  var courseTaskService: CourseTaskService = _

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
    syllabus.creditHours = syllabus.course.creditHours
    putBasicDatas(syllabus.course)

    given project: Project = syllabus.course.project

    put("examHours", 0)
    val first = findScheduledClazz(syllabus.course, syllabus.semester)
    first foreach { clazz =>
      //根据排课课时测算考核课时
      val scheduleHours = LessonSchedule.convert(clazz).map(_.hours).sum
      if (scheduleHours <= syllabus.course.creditHours) {
        put("examHours", syllabus.course.creditHours - scheduleHours)
      }
    }

    //topic item
    put("topicLabels", getCodes(classOf[SyllabusTopicLabel]))

    //textbook item
    if (get("step").contains("textbook")) {
      put("textbooks", entityDao.getAll(classOf[Textbook]))
      if (syllabus.textbooks.isEmpty) {
        val materials = entityDao.findBy(classOf[ClazzMaterial], "clazz.course" -> syllabus.course, "clazz.semester" -> syllabus.semester)
        val books = materials.flatMap(_.books).distinct
        syllabus.textbooks.addAll(books)
      }
      put("director", courseTaskService.getOfficeDirector(syllabus.course, syllabus.department, syllabus.semester))
      put("me", Securities.user)
      put("warningMessages", validate(syllabus))
    }
    if (get("step").contains("requirements")) {
      val orderedOutcomes = syllabus.outcomes.sortBy(_.idx)
      var idx = 1
      //修复顺序号
      orderedOutcomes foreach { o =>
        o.idx = idx
        idx += 1
      }
      entityDao.saveOrUpdate(syllabus)
      val requirements = orderedOutcomes.map(_.title)
      if (requirements.isEmpty) {
        if (syllabus.locale == Locale.SIMPLIFIED_CHINESE) {
          requirements.addAll(entityDao.getAll(classOf[GraduateObjective]).sortBy(_.code).map(_.name))
        } else {
          requirements.addAll(entityDao.getAll(classOf[GraduateObjective]).sortBy(_.code).map(_.enName2))
        }
      }
      put("requirements", requirements)
    }
    if (get("step").contains("topics")) {
      put("teachingMethods", syllabus.teachingMethods.map(x => (x, x)).toMap)
      put("validateHourMessages", validateHours(syllabus))
    }
    if (get("step").isEmpty) {
      val majors = entityDao.findBy(classOf[Major], "project" -> syllabus.course.project)
      val courseMajors = majors.filter(m => m.active && m.journals.exists(_.depart == syllabus.department))
      put("majors", courseMajors)
    }
    val locale = syllabus.locale
    get("step") match
      case None => forward(s"${locale}/form")
      case Some(s) => forward(s"${locale}/${s}")
  }

  def remove(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    if (syllabus.writer.code == Securities.user) {
      entityDao.remove(syllabus)
      businessLogger.info(s"删除课程教学大纲:${syllabus.course.name}", syllabus.id, Map("syllabus" -> syllabus.id.toString))
      redirect("course", s"course.id=${syllabus.course.id}", "删除成功")
    } else {
      redirect("course", s"course.id=${syllabus.course.id}", "只能删除自己编写的大纲")
    }
  }

  private def putBasicDatas(course: Course): Unit = {
    given project: Project = course.project

    put("project", project)
    put("departments", List(course.department))
    put("teachingNatures", getCodes(classOf[TeachingNature]))
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

    put("locales", Map(new Locale("zh", "CN") -> "中文大纲", new Locale("en", "US") -> "English Syllabus"))
  }

  @mapping(value = "new", view = "new,form")
  def editNew(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))

    given project: Project = course.project

    putBasicDatas(course)
    val semester = getSemester
    val syllabus = newSyllabus(course, semester)
    put("course", course)
    put("syllabus", syllabus)
    val locale = get("locale", classOf[Locale]).getOrElse(Locale.SIMPLIFIED_CHINESE)
    put("locale", locale)
    val majors = entityDao.findBy(classOf[Major], "project" -> syllabus.course.project)
    val courseMajors = majors.filter(m => m.active && m.journals.exists(_.depart == syllabus.department))
    put("majors", courseMajors)
    get("step") match
      case None => forward(s"${locale}/form")
      case Some(s) => forward(s"${locale}/${s}")
  }

  private def findScheduledClazz(course: Course, semester: Semester): Option[Clazz] = {
    entityDao.findBy(classOf[Clazz], "course" -> course, "semester" -> semester).find(_.schedule.activities.nonEmpty)
  }

  private def newSyllabus(course: Course, semester: Semester): Syllabus = {
    val syllabus = new Syllabus
    syllabus.course = course
    syllabus.department = course.department
    syllabus.examMode = course.examMode
    syllabus.gradingMode = course.gradingMode
    syllabus.creditHours = course.creditHours
    syllabus.weekHours = course.weekHours
    syllabus.semester = semester
    put("examHours", 0)
    val first = findScheduledClazz(course, semester)
    first match
      case None =>
        if (course.defaultCredits > 1 || course.creditHours >= 30) {
          syllabus.examCreditHours = course.defaultCredits.toInt
          put("examHours", syllabus.examCreditHours)
        }
      case Some(clazz) =>
        //根据排课课时测算考核课时
        val scheduleHours = LessonSchedule.convert(clazz).map(_.hours).sum
        if (scheduleHours < course.creditHours) {
          syllabus.examCreditHours = course.creditHours - scheduleHours
        }
        put("examHours", syllabus.examCreditHours)
    syllabus
  }

  def save(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))

    given project: Project = course.project

    val me = entityDao.findBy(classOf[User], "code", Securities.user).head
    val syllabus = populateEntity()
    if (null == syllabus.beginOn) {
      syllabus.beginOn = entityDao.get(classOf[Semester], syllabus.semester.id).beginOn
    }
    if (!syllabus.persisted) {
      syllabus.course = course
    }
    if null == syllabus.description then syllabus.description = "--"
    populateHours(syllabus)
    syllabus.writer = me
    syllabus.updatedAt = Instant.now
    syllabus.creditHours = course.creditHours

    val majorIds = getLongIds("major")
    syllabus.majors.clear()
    syllabus.majors.addAll(entityDao.find(classOf[Major], majorIds))
    entityDao.saveOrUpdate(syllabus)
    businessLogger.info(s"保存了课程教学大纲:${course.name}", syllabus.id, Map("course" -> course.id.toString))
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
    val deprecated = syllabus.hours.filter(x => !teachingNatures.contains(x.nature))
    syllabus.hours.subtractAll(deprecated)

    teachingNatures foreach { ht =>
      val creditHour = getInt("examHour" + ht.id)
      syllabus.examHours find (h => h.nature == ht) match {
        case Some(hour) =>
          if (creditHour.isEmpty) {
            syllabus.examHours -= hour
          } else {
            hour.creditHours = creditHour.getOrElse(0)
          }
        case None =>
          if (creditHour.isDefined) {
            syllabus.examHours += new SyllabusExamHour(syllabus, ht, creditHour.getOrElse(0))
          }
      }
    }
    val deprecated2 = syllabus.examHours.filter(x => !teachingNatures.contains(x.nature))
    syllabus.examHours.subtractAll(deprecated2)
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

  /** 保存毕业要求
   *
   * @return
   */
  def saveRequirements(): View = {
    val syllabus = populateEntity()
    syllabus.updatedAt = Instant.now
    (1 to 12) foreach { idx =>
      val code = s"R${idx}"
      val name = get(code, "")
      if (Strings.isNotEmpty(name)) {
        syllabus.outcomes.find(_.idx == idx) match
          case None =>
            val g = new SyllabusOutcome(syllabus, idx, name, " ", " ")
            syllabus.outcomes.addOne(g)
          case Some(outcome) => outcome.title = name
      } else {
        syllabus.outcomes.find(_.code == code) foreach {
          syllabus.outcomes.subtractOne
        }
      }
    }
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  def saveOutcomes(): View = {
    val syllabus = populateEntity()
    syllabus.updatedAt = Instant.now

    given project: Project = getProject

    syllabus.outcomes foreach { r =>
      val prefix = s"R${r.id}"
      val cos = Strings.split(get(prefix + ".courseObjectives", "")).toSeq.sorted.mkString(",")
      val contents = get(prefix + ".contents", "")
      r.contents = contents
      r.courseObjectives = cos
    }
    entityDao.saveOrUpdate(syllabus)
    toStep(syllabus)
  }

  def editTopic(): View = {
    val topic = entityDao.get(classOf[SyllabusTopic], getLongId("topic"))

    given project: Project = topic.syllabus.course.project

    put("teachingNatures", getCodes(classOf[TeachingNature]))
    put("topicLabels", getCodes(classOf[SyllabusTopicLabel]))
    put("topic", topic)
    put("teachingMethods", topic.syllabus.teachingMethods.map(x => (x, x)).toMap)
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
    val deprecated = topic.hours.filter(x => !teachingNatures.contains(x.nature))
    topic.hours.subtractAll(deprecated)

    val objectives = entityDao.find(classOf[SyllabusObjective], getLongIds("objective"))
    topic.objectives = None
    if (objectives.nonEmpty) {
      topic.objectives = Some(objectives.map(_.code).mkString(","))
    }
    val methods = getAll("teachingMethod", classOf[String])
    topic.methods = None
    val sep = if syllabus.locale == Locale.SIMPLIFIED_CHINESE then "、" else ","
    topic.methods = Some(methods.mkString(sep))
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
      design.idx = syllabus.designs.size
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
              val hours = getInt(s"experiment${i}.creditHours", 0)
              syllabus.experiments += new SyllabusExperiment(syllabus, i, name, hours, experimentType, online)
            }
          case Some(c) =>
            if Strings.isBlank(name) then syllabus.experiments -= c
            else
              val experimentType = entityDao.get(classOf[ExperimentType], getInt(s"experiment${i}.experimentType.id", 0))
              val online = getBoolean(s"experiment${i}.online", false)
              val hours = getInt(s"experiment${i}.creditHours", 0)
              c.name = name
              c.creditHours = hours
              c.experimentType = experimentType
              c.online = online

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

    //max 7
    (0 to 6) foreach { i =>
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
    val assessment =
      if componentName.isEmpty then syllabus.getAssessment(gradeType, null).getOrElse(new SyllabusAssessment(syllabus, gradeType, None))
      else syllabus.getUsualAssessment(index).getOrElse(new SyllabusAssessment(syllabus, gradeType, componentName))

    if (!assessment.persisted) {
      syllabus.assessments += assessment
    }
    assessment.idx = index
    val prefix = componentName match
      case None => "grade" + gradeType.id
      case Some(n) => "grade" + gradeType.id + "_" + index
    populate(assessment, prefix)
    val percents = Collections.newMap[String, Int]
    if (assessment.scorePercent >= 0 && !(gradeType.id == GradeType.Usual && index == 0 && componentName.isEmpty)) {
      syllabus.objectives foreach { co =>
        val p =
          if gradeType.id == GradeType.Usual then getInt(s"usual_${index}_co${co.id}", 0)
          else getInt(s"end_co${co.id}", 0)
        if p > 0 then percents.put(co.code, p)
      }
    }
    assessment.updateObjectivePercents(percents.toMap)

    assessment.component foreach { n =>
      var name = Strings.replace(n, "\r", "")
      name = Strings.replace(n, "\n", "")
      name = Strings.replace(n, " ", "")
      assessment.component = Some(name)
    }
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
    getBoolean("submit") foreach { s =>
      syllabus.office = courseTaskService.getOffice(syllabus.course, syllabus.department, syllabus.semester)
      syllabus.office foreach { o =>
        syllabus.reviewer = courseTaskService.getOfficeDirector(syllabus.course, syllabus.department, syllabus.semester)
      }
      syllabus.status = Submited
      entityDao.saveOrUpdate(syllabus)
      businessLogger.info(s"提交课程教学大纲:${syllabus.course.name}", syllabus.id, Map("course" -> syllabus.course.id.toString))
    }
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
    put("editables", Set(AuditStatus.Draft, AuditStatus.Submited, AuditStatus.RejectedByDirector, AuditStatus.RejectedByDepart))

    val last = entityDao.findBy(classOf[CourseProfile], "course", course).sortBy(_.beginOn).lastOption
    put("profile", last)
    forward()
  }

  def editProfile(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val profile = getLong("profile.id") match
      case None =>
        val profile = new CourseProfile
        profile.course = course
        profile
      case Some(profileId) => entityDao.get(classOf[CourseProfile], profileId)
    put("profile", profile)
    forward()
  }

  /** 保存简介
   *
   * @return
   */
  def saveProfile(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val profile = getLong("profile.id") match
      case None =>
        val profile = new CourseProfile
        profile.course = course
        profile
      case Some(profileId) => entityDao.get(classOf[CourseProfile], profileId)
    profile.description = get("description", "")
    profile.enDescription = get("enDescription")
    profile.updatedAt = Instant.now
    entityDao.saveOrUpdate(profile)
    redirect("courseInfo", s"course.id=${course.id}", "info.save.success")
  }

  /** 显示课程基本信息
   *
   * @return
   */
  def courseInfo(): View = {
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val last = entityDao.findBy(classOf[CourseProfile], "course", course).sortBy(_.beginOn).lastOption
    put("course", course)
    put("profile", last)
    forward()
  }

  def info(): View = {
    val syllabus = entityDao.get(classOf[Syllabus], getLongId("syllabus"))
    new SyllabusHelper(entityDao).collectDatas(syllabus) foreach { case (k, v) => put(k, v) }
    forward(s"/org/openurp/edu/course/syllabus/${syllabus.course.project.school.id}/${syllabus.course.project.id}/report_${syllabus.locale}")
  }

  private def validate(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    if (syllabus.creditHours > 0 && syllabus.topics.isEmpty) {
      messages += "缺少课程主题"
    }
    if (syllabus.designs.isEmpty) {
      messages += "缺少教学设计"
    }

    messages ++= validateHours(syllabus)
    messages ++= validAssessment(syllabus)
    messages.toSeq
  }

  /** 验证考核比例
   *
   * @param syllabus
   * @return
   */
  private def validAssessment(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    val usualType = entityDao.get(classOf[GradeType], GradeType.Usual)
    val endType = entityDao.get(classOf[GradeType], GradeType.End)
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

  private def validateHours(syllabus: Syllabus): Seq[String] = {
    val messages = Collections.newBuffer[String]
    var total = 0
    syllabus.hours foreach { h =>
      total += h.creditHours
    }
    if total != syllabus.course.creditHours then
      messages += s"课程要求${syllabus.course.creditHours}课时，分项累计${total}课时，请检查。"

    val totalExamHours = syllabus.examHours.map(_.creditHours).sum
    if totalExamHours != syllabus.examCreditHours then
      messages += s"大纲考核要求${syllabus.examCreditHours}课时，分项累计${totalExamHours}课时，请检查。"

    syllabus.hours foreach { h =>
      var t = 0;
      syllabus.topics foreach { p =>
        t += p.getHour(h.nature).map(_.creditHours).getOrElse(0)
      }
      t += syllabus.examHours.find(_.nature == h.nature).map(_.creditHours).getOrElse(0)
      if (t != h.creditHours) {
        messages += s"课程要求${h.nature.name}${h.creditHours}课时，教学内容累计${t}课时，请检查。"
      }
    }
    var totalLearningHours = 0
    syllabus.topics foreach { t =>
      totalLearningHours += t.learningHours
    }
    if (totalLearningHours != syllabus.learningHours) {
      messages += s"自主学习要求${syllabus.learningHours}课时，教学内容累计${totalLearningHours}课时，请检查。"
    }

    syllabus.topics foreach { p =>
      val hours = p.hours.map(_.creditHours).sum
      if (hours == 0) {
        if (p.hours.isEmpty) {
          messages += s"教学主题:${p.name},缺少学时分布"
        } else {
          messages += s"教学主题:${p.name},学时为0"
        }
      }

      if (p.methods.isEmpty) {
        messages += s"教学主题:${p.name},缺少教学方法"
      }
    }
    messages.toSeq
  }
}
