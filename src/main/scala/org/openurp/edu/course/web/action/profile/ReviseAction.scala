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

package org.openurp.edu.course.web.action.profile

import jakarta.servlet.http.Part
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.commons.net.http.HttpUtils
import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.ems.app.{Ems, EmsApp}
import org.beangle.security.Securities
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.context.ActionContext
import org.beangle.webmvc.support.ServletSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.BookAdoption.{UseLecture, UseTextBook}
import org.openurp.base.edu.model.{BookAdoption, Course, CourseProfile, Textbook}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{AuditStatus, Project, Semester, User}
import org.openurp.edu.clazz.domain.ClazzProvider
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseTask, SyllabusDoc}
import org.openurp.edu.course.service.{CourseTaskService, SyllabusService}
import org.openurp.edu.course.web.helper.StatHelper
import org.openurp.starter.web.support.TeacherSupport

import java.net.URL
import java.time.Instant
import java.util.Locale

/**
 * 教师修读教学大纲
 */
class ReviseAction extends TeacherSupport, EntityAction[CourseProfile], ServletSupport {

  var syllabusService: SyllabusService = _

  var courseTaskService: CourseTaskService = _

  var clazzProvider: ClazzProvider = _

  var businessLogger: WebBusinessLogger = _

  override def projectIndex(teacher: Teacher)(using project: Project): View = {
    val semester = getSemester

    val tasks = courseTaskService.getTasks(project, semester, teacher)

    //修订任务
    val taskCourses = tasks.map(_.course)

    //本学期课程
    val clazzCourses = clazzProvider.getClazzes(semester, teacher, project).map(_.course).toSet.toBuffer.subtractAll(taskCourses)

    //历史课程
    val query2 = OqlBuilder.from[Course](classOf[Clazz].getName, "c")
    query2.where(":teacher in elements(c.teachers)", teacher)
    query2.where("c.semester.endOn <= :today", semester.endOn)
    query2.select("distinct c.course")
    query2.orderBy("c.course.code")
    val hisCourses = Collections.newBuffer(entityDao.search(query2))
    hisCourses.subtractAll(clazzCourses)

    val statHelper = new StatHelper(entityDao)
    val courses = clazzCourses ++ hisCourses
    put("hasProfileCourses", statHelper.hasSyllabus(courses))
    put("hasSyllabusCourses", statHelper.hasProfile(courses))
    put("taskCourses", taskCourses)
    put("clazzCourses", clazzCourses)
    put("hisCourses", hisCourses)
    put("courses", courses)
    put("zh_template_url", getTemplateFile("zh.docx"))
    put("en_template_url", getTemplateFile("en.docx"))
    put("semester", semester)
    forward()
  }

  def getTemplateFile(name: String): Option[URL] = {
    val url = new URL(s"${Ems.api}/platform/config/files/${EmsApp.name}/syllabus/template/$name")
    val status = HttpUtils.access(url)
    if (status.isOk) {
      Some(url)
    } else {
      None
    }
  }

  @mapping("{courseId}")
  def course(@param("courseId") courseId: String): View = {
    val course = entityDao.get(classOf[Course], courseId.toLong)
    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val teacher = getTeacher
    val task = courseTaskService.getOrCreateTask(semester, course, teacher)

    put("task", task)
    put("editable", task.nonEmpty && task.head.director.contains(teacher))
    put("course", course)
    put("me", teacher.code)

    //这里需要展示该学期有效的profile和历史所有大纲
    put("profile", getProfile(course, semester))
    val docQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    docQuery.where("s.course = :course and s.beginOn <= :beginOn", course, semester.beginOn)
    docQuery.orderBy("s.semester.beginOn desc")

    val docs = entityDao.search(docQuery)
    val activeDocs = docs.filter(_.within(semester.beginOn))
    put("activeDocs", activeDocs)
    put("historyDocs", docs.toBuffer.subtractAll(activeDocs))

    val statHelper = new StatHelper(entityDao)
    put("clazzInfos", statHelper.statClazzInfo(course))
    put("semester", semester)
    forward()
  }

  def editProfile(): View = {
    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val course = entityDao.get(classOf[Course], getLongId("course"))
    val profile = getProfile(course, semester) match {
      case Some(p) => p
      case None => val cp = new CourseProfile
        cp.course = course
        cp.semester = semester
        cp.beginOn = semester.beginOn
        cp
    }
    put("semester", semester)
    put("profile", profile)
    put("course", course)
    put("project", course.project)
    val syllabusQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    syllabusQuery.limit(1, 1)
    val writer = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    put("writer", writer)
    put("syllabusDocs", entityDao.search(syllabusQuery))
    put("Ems", Ems)
    put("bookAdoptions", BookAdoption.values.filter(_.id > 0).map(x => (x.id, x.name)).toMap)
    forward("form")
  }

  private def getProfile(course: Course, semester: Semester): Option[CourseProfile] = {
    val renew = getBoolean("renew", false)
    if (renew) {
      None
    } else {
      val query = OqlBuilder.from(classOf[CourseProfile], "cp")
      query.where("cp.course = :course", course)
      query.where("cp.beginOn<=:beginOn", semester.beginOn)
      query.where("cp.endOn is null or cp.endOn >=:beginOn", semester.beginOn)
      entityDao.search(query).headOption
    }
  }

  @mapping(value = "{id}", method = "put")
  def update(@param("id") id: String): View = {
    val entity = populate(getModel(id), simpleEntityName)
    persist(entity)
  }

  override protected def simpleEntityName: String = {
    "profile"
  }

  def persist(profile: CourseProfile): View = {
    val course = entityDao.get(classOf[Course], profile.course.id)
    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    profile.books.clear()
    profile.books.addAll(entityDao.find(classOf[Textbook], getLongIds("textbook")))
    if (profile.books.isEmpty) {
      if (profile.bookAdoption == UseTextBook) profile.bookAdoption = UseLecture
    } else {
      profile.bookAdoption = UseTextBook
    }

    profile.updatedAt = Instant.now
    if (null == profile.beginOn) profile.beginOn = semester.beginOn
    if (null == profile.department) profile.department = course.department
    profile.submitAt = Some(Instant.now)

    val user = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    profile.writer = user
    entityDao.saveOrUpdate(profile)
    //处理profile的生命周期
    val q = OqlBuilder.from(classOf[CourseProfile], "cp")
    q.where("cp.course=:course", course)
    q.orderBy("cp.beginOn desc")
    val profiles = entityDao.findBy(classOf[CourseProfile], "course", course)
    profiles foreach { p =>
      p.endOn foreach { endOn =>
        p.beginOn = p.semester.beginOn
      }
    }

    var last: Option[CourseProfile] = None
    profiles.sortBy(_.beginOn).reverse foreach { p =>
      last match {
        case None => last = Some(p)
        case Some(l) =>
          p.endOn = Some(l.beginOn.minusDays(1))
          last = Some(p)
      }
    }
    entityDao.saveOrUpdate(profiles)

    val parts = getAll("attachment", classOf[Part])
    val writerId = getLong("syllabusDoc.writer.id")
    if (parts.nonEmpty && parts.head.getSize > 0 && writerId.nonEmpty) {
      val part = parts.head
      val writer = entityDao.get(classOf[User], writerId.get)
      val doc = syllabusService.upload(course, writer, part.getInputStream,
        Strings.substringAfterLast(part.getSubmittedFileName, "."),
        Locale.SIMPLIFIED_CHINESE, Instant.now)
      doc.status = AuditStatus.Published
      entityDao.saveOrUpdate(doc)
    }
    redirect("course", "courseId=" + profile.course.id + "&semester.id=" + semester.id, "info.save.success")
  }

  @mapping(method = "post")
  def save(): View = {
    val course = entityDao.get(classOf[Course], getLongId("profile.course"))
    val p = populateEntity()
    val rs = persist(p)
    businessLogger.info(s"修改课程简介信息:${course.code} ${course.name}", p.id, ActionContext.current.params)
    rs
  }

  def attachment(): View = {
    val doc = entityDao.get(classOf[SyllabusDoc], getLongId("doc"))
    val path = EmsApp.getBlobRepository(true).url(doc.docPath)
    response.sendRedirect(path.get.toString)
    null
  }

  def changeDirector(): View = {
    val director = entityDao.get(classOf[Teacher], getLongId("director"))
    val task = entityDao.get(classOf[CourseTask], getLongId("task"))
    val teacher = getTeacher
    if (task.teachers.contains(teacher) && (task.director.isEmpty || task.director.contains(teacher))) {
      task.director = Some(director)
      entityDao.saveOrUpdate(task)
      businessLogger.info(s"修改课程负责人:${task.course.code} ${task.course.name}为：${director.name}", task.id, ActionContext.current.params)
    }

    redirect("course", s"&courseId=${task.course.id}&semester.id=${task.semester.id}", "更改成功")
  }
}
