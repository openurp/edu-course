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

package org.openurp.edu.course.web.action.program

import jakarta.servlet.http.Part
import org.beangle.commons.collection.{Collections, Properties}
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.core.PrintOptions
import org.beangle.doc.pdf.SPDConverter
import org.beangle.ems.app.EmsApp.path
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.ems.app.{Ems, EmsApi, EmsApp}
import org.beangle.security.Securities
import org.beangle.webmvc.annotation.response
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.{Stream, View}
import org.openurp.base.edu.model.Course
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Project, User}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.*
import org.openurp.edu.course.service.CourseTaskService
import org.openurp.edu.course.web.helper.{ClazzPlanHelper, ClazzProgramHelper, LessonDesignDocParser}
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}
import org.openurp.starter.web.helper.ProjectProfile
import org.openurp.starter.web.support.TeacherSupport

import java.io.{ByteArrayInputStream, File}
import java.net.URI
import java.time.Instant

class ReviseAction extends TeacherSupport, EntityAction[ClazzProgram] {
  var clazzProvider: ClazzProvider = _
  var businessLogger: WebBusinessLogger = _
  var courseTaskService: CourseTaskService = _

  protected override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val semester = getSemester
    put("semester", semester)

    val clazzes = Collections.newSet[Clazz]
    val myClazzes = clazzProvider.getClazzes(semester, teacher, project).filter(_.schedule.activities.nonEmpty).sortBy(_.crn)

    val q = OqlBuilder.from(classOf[CourseTask], "c")
    q.where("c.course.project=:project", project)
    q.where("c.semester=:semester", semester)
    q.where("c.director=:me", teacher)
    val tasks = entityDao.search(q)

    if (tasks.nonEmpty) {
      val helper = new ClazzPlanHelper(entityDao)
      tasks foreach { task => clazzes.addAll(helper.getCourseTaskClazzes(task)) }
    }
    val scheduled = clazzes.filter(_.schedule.activities.nonEmpty).toBuffer.sortBy(_.crn)
    scheduled.subtractAll(myClazzes)
    scheduled.prependAll(myClazzes)

    if (scheduled.nonEmpty) {
      put("plans", entityDao.findBy(classOf[ClazzPlan], "clazz", scheduled).map(x => (x.clazz, x)).toMap)
      val clazzPrograms = entityDao.findBy(classOf[ClazzProgram], "clazz", scheduled)
      put("programs", clazzPrograms.map(x => (x.clazz, x)).toMap)
      val courses = scheduled.map(_.course).toSet

      val p = OqlBuilder.from(classOf[ClazzProgram], "c")
      p.where("c.clazz.project=:project", project)
      p.where("c.semester=:semester", semester)
      p.where("c.clazz.course in(:courses)", courses)
      val programs = entityDao.search(p)

      val tasks = new ClazzPlanHelper(entityDao).findCourseTasks(scheduled).values
      val coursePrograms = Collections.newMap[Course, ClazzProgram]
      tasks foreach { task =>
        programs.find(p => p.clazz.course == task.course && task.director.get.code == p.writer.code) foreach { pr =>
          coursePrograms.put(task.course, pr)
        }
      }
      put("coursePrograms", coursePrograms)
    } else {
      put("plans", Map.empty)
      put("programs", Map.empty)
    }
    put("clazzes", scheduled)
    forward()
  }

  def edit(): View = {
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))
    val plan = entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).head
    put("clazz", clazz)
    put("plan", plan)
    put("schedules", LessonSchedule.convert(clazz))
    put("schedule", ScheduleDigestor.digest(clazz, ":day :units(:time) :weeks :room"))
    val programs = entityDao.findBy(classOf[ClazzProgram], "clazz", clazz)
    val program = programs.headOption.getOrElse(new ClazzProgram(clazz))
    if (!program.persisted) {
      program.writer = entityDao.findBy(classOf[User], "school" -> plan.clazz.project.school, "code" -> Securities.user).head
      program.updatedAt = Instant.now
      entityDao.saveOrUpdate(program)
    }
    put("program", program)
    val project = program.clazz.project
    ProjectProfile.set(project)
    forward()
  }

  def info(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val clazz = entityDao.get(classOf[Clazz], getLongId("clazz"))
    val plan = entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).head
    put("clazz", clazz)
    put("plan", plan)
    put("schedules", LessonSchedule.convert(clazz))
    put("schedule", ScheduleDigestor.digest(clazz, ":day :units(:time) :weeks :room"))
    put("program", program)
    val project = program.clazz.project
    ProjectProfile.set(project)
    forward()
  }

  def save(): View = {
    forward()
  }

  def editDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val design =
      getLong("design.id") match
        case Some(id) => entityDao.get(classOf[LessonDesign], id)
        case None =>
          val idx = getInt("idx", 1)
          program.get(idx).getOrElse(new LessonDesign(program, idx))

    val schedules = LessonSchedule.convert(program.clazz)
    if (design.idx - 1 < schedules.length) {
      design.creditHours = schedules(design.idx - 1).hours
    }
    getLong("from.id") foreach { fromId =>
      val fromDesign = entityDao.get(classOf[LessonDesign], fromId)
      copyTo(fromDesign, design)
      put("fromDesign", fromDesign)
    }
    val q = OqlBuilder.from(classOf[LessonDesign], "d")
    q.where("d.program.clazz.project=:project", program.clazz.project)
    q.where("d.idx = :idx", design.idx)
    q.where("d.program.clazz.course=:course", program.clazz.course)
    q.where("d.program.clazz.semester=:semester", program.clazz.semester)
    if (design.persisted) {
      q.where("d.id!=:me", design.id)
    }
    val otherDesigns = entityDao.search(q).toBuffer

    //自己编写的历史教案，或者同课程其他教案
    val q2 = OqlBuilder.from(classOf[LessonDesign], "d")
    q2.where("d.program.clazz.project=:project", program.clazz.project)
    q2.where("d.idx = :idx", design.idx)
    q2.where("d.program.clazz.semester.beginOn <:beginOn", program.clazz.semester.beginOn)
    q2.where("(d.program.clazz.course=:course or d.program.writer.code=:me)", program.clazz.course, Securities.user)
    otherDesigns.addAll(entityDao.search(q2))

    put("otherDesigns", otherDesigns)
    put("design", design)
    put("program", program)
    forward()
  }

  @response
  def uploadImage(): Properties = {
    val rs = new Properties()
    rs.put("error", 0)
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val teacher = getTeacher
    val clazz = program.clazz
    get("imgFile", classOf[Part]) match
      case Some(part) =>
        val blob = EmsApp.getBlobRepository(true)
        val storeName = part.getSubmittedFileName
        val meta = blob.upload(s"/course/program/${program.id}/",
          part.getInputStream, storeName, teacher.code + " " + teacher.name)
        rs.put("url", blob.path(meta.filePath).get)
        rs.put("message", "上传成功")
      case None =>
        rs.put("error", 1)
        rs.put("message", "图片不能为空")

    rs
  }

  def saveDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val idx = getInt("design.idx", 1)
    val design = program.get(idx).getOrElse(new LessonDesign(program, idx))
    if (!design.persisted) {
      program.designs.addOne(design)
    }
    design.subject = get("design.subject", "")
    design.homework = get("design.homework")
    val clazz = program.clazz
    populateText(design, "design.target")
    populateText(design, "design.emphasis")
    populateText(design, "design.difficulties")
    populateText(design, "design.resources")
    populateText(design, "design.values")
    (1 to 10) foreach { i =>
      val title = get(s"sections[${i}].title", "")
      val duration = getInt(s"sections[${i}].duration", 0)
      val summary = get(s"sections[${i}].summary", " ").trim()
      val details = get(s"sections[${i}].details", " ").trim()
      if Strings.isNotBlank(title) then
        val section = design.getSection(i).getOrElse(new LessonDesignSection(design, i, title, duration, summary, details))
        section.title = title
        section.duration = duration
        section.summary = summary
        section.details = details
        design.sections += section
        if (!section.persisted) {
          design.sections += section
        }
      else
        design.getSection(i) foreach { section =>
          design.sections.subtractOne(section)
        }
    }
    ClazzProgramHelper.updateStatInfo(program)
    entityDao.saveOrUpdate(design)
    businessLogger.info(s"保存了教案:${clazz.course.name} 第${idx}次课", design.id, Map("program" -> program.id.toString))
    redirect("designInfo", s"design.id=${design.id}&editable=1", "info.save.success")
  }

  def designInfo(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    val clazz = design.program.clazz
    val plan = entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).head
    put("plan", plan)
    put("program", design.program)
    forward()
  }

  def designReport(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    put("design", design)
    val clazz = getLong("clazz.id") match {
      case None => design.program.clazz
      case Some(clazzId) => entityDao.get(classOf[Clazz], clazzId)
    }

    put("plan", entityDao.findBy(classOf[ClazzPlan], "clazz", clazz).headOption)
    val syllabus = ClazzPlanHelper(entityDao).findSyllabus(clazz)
    put("clazz", clazz)
    put("syllabus", syllabus)
    val project = design.program.clazz.project
    ProjectProfile.set(project)
    forward("/org/openurp/edu/course/web/components/program/designReport")
  }

  def designPdf(): View = {
    val id = getLongId("design")
    val clazzId = getLongId("clazz")
    val design = entityDao.get(classOf[LessonDesign], id)
    val url = EmsApi.url(s"/program/revise/designReport?design.id=${id}&clazz.id=${clazzId}")
    val pdf = File.createTempFile("doc", ".pdf")
    val options = new PrintOptions
    SPDConverter.getInstance().convert(URI.create(url), pdf, options)

    val clazz = design.program.clazz
    Stream(pdf, clazz.crn + "_" + clazz.course.name + s" 授课教案 第${design.idx}次课.pdf").cleanup(() => pdf.delete())
  }

  private def populateText(design: LessonDesign, name: String): Unit = {
    val contents = cleanText(get(name, ""))
    val textName = name.substring("design.".length)
    design.getText(textName) match {
      case None =>
        if Strings.isNotBlank(contents) then
          val o = new LessonDesignText(design, textName, contents)
          design.texts += o
      case Some(o) =>
        if Strings.isBlank(contents) then
          design.texts -= o
        else
          o.contents = contents
    }
  }

  def importSetting(): View = {
    put("program", entityDao.get(classOf[ClazzProgram], getLongId("program")))
    put("idx", getInt("idx", 1))
    forward()
  }

  def importDesign(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    val index = getInt("idx", 0)
    put("program", program)
    put("idx", index)

    val teacher = getTeacher
    get("attachment", classOf[Part]) match
      case Some(part) =>
        val rs = new LessonDesignDocParser().parse(part.getInputStream)
        if (rs._1.nonEmpty) {
          val design =
            program.get(index) match
              case Some(d) =>
                copyTo(rs._1.get, d)
              case None =>
                val d = rs._1.get
                d.idx = index
                d.program = program
                program.designs.addOne(d)
                d
          ClazzProgramHelper.updateStatInfo(program)

          val blob = EmsApp.getBlobRepository(true)
          rs._2.foreach { doc =>
            doc.images foreach { (name, data) =>
              val meta = blob.upload(s"/course/program/${program.id}/${design.id}/",
                new ByteArrayInputStream(data), name, teacher.code + " " + teacher.name)
              design.sections foreach { section =>
                var path = blob.path(meta.filePath).get
                path = path.substring(Ems.base.length)
                section.summary = section.summary.replaceAll(name, path)
                section.details = section.details.replaceAll(name, path)
                design.homework foreach { hw =>
                  design.homework = Some(hw.replaceAll(name, path))
                }
              }
            }
          }
          entityDao.saveOrUpdate(design)
          businessLogger.info(s"导入教案:${program.clazz.course.name} 第${index}次课", design.id, Map("program" -> program.id.toString))
          redirect("designInfo", s"design.id=${design.id}&editable=1", "识别完成，请核对")
        } else {
          addError("文件解析错误，请检查是否符合模板要求:" + rs._3)
          forward("importSetting")
        }
      case None =>
        addError("缺少word文件")
        forward("importSetting")
  }

  private def copyTo(src: LessonDesign, dest: LessonDesign): LessonDesign = {
    dest.homework = src.homework
    dest.subject = src.subject
    src.texts foreach { st =>
      val k = st.name
      val v = st.contents
      dest.getText(k) match
        case Some(t) => t.contents = v
        case None => val t = new LessonDesignText(dest, k, v)
          dest.texts.addOne(t)
    }
    val textNames = src.texts.map(_.name).toSet
    val abandons = dest.texts.filter(x => !textNames.contains(x.name))
    dest.texts.subtractAll(abandons)
    src.sections foreach { section =>
      dest.getSection(section.idx) match
        case Some(ds) => ds.idx = section.idx
          ds.duration = section.duration
          ds.title = section.title
          ds.summary = section.summary
          ds.details = section.details
        case None =>
          val ds = new LessonDesignSection(dest, section.idx, section.title, section.duration, section.summary, section.details)
          dest.sections.addOne(ds)
    }
    val sectionIndices = src.sections.map(_.idx).toSet
    val abandonSections = dest.sections.filter(x => !sectionIndices.contains(x.idx))
    dest.sections.subtractAll(abandonSections)
    dest
  }

  def removeDesign(): View = {
    val design = entityDao.get(classOf[LessonDesign], getLongId("design"))
    val program = design.program
    program.designs.subtractOne(design)
    ClazzProgramHelper.updateStatInfo(program)
    entityDao.remove(design)
    businessLogger.info(s"删除教案:${program.clazz.course.name} 第${design.idx}次课", design.id, Map("program" -> program.id.toString))
    redirect("edit", s"clazz.id=${program.clazz.id}", "删除成功")
  }

  def remove(): View = {
    val program = entityDao.get(classOf[ClazzProgram], getLongId("program"))
    if (program.writer.code == Securities.user) {
      if (program.designs.isEmpty) {
        entityDao.remove(program)
        redirect("index", "删除成功")
      } else {
        redirect("index", "该教案内部还有内容，无法删除,删除失败")
      }
    } else {
      redirect("index", "删除失败")
    }
  }

  def copyDesign(): View = {
    val id = getLongId("from")
    forward()
  }

  /**
   * 清理文本内容，移除换行符和回车符。
   *
   * 该函数的目的是为了处理文本，确保文本中不包含任何的回车符(\r)或换行符(\n)。
   * 这对于一些需要统一文本格式的场景非常有用，比如处理从不同来源获取的文本数据。
   *
   * @param contents 待清理的文本字符串。
   * @return 清理后的文本字符串，不包含任何回车符或换行符。
   */
  private def cleanText(contents: String): String = {
    Strings.replace(contents, "\r", "").trim()
  }

  def report(): View = {
    forward()
  }

  def pdf(): View = {
    val id = getLongId("plan")
    val plan = entityDao.get(classOf[ClazzPlan], id)
    forward()
  }
}
