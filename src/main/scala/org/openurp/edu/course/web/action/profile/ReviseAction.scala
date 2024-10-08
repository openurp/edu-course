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
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.{Ems, EmsApp}
import org.beangle.security.Securities
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.{ActionSupport, ServletSupport}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Course, CourseProfile}
import org.openurp.base.model.{AuditStatus, User}
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{Syllabus, SyllabusDoc}
import org.openurp.edu.course.service.SyllabusService
import org.openurp.edu.course.web.helper.StatHelper

import java.net.URL
import java.time.{Instant, LocalDate}
import java.util.Locale

/**
 * 教师修读教学大纲
 */
class ReviseAction extends ActionSupport, EntityAction[CourseProfile], ServletSupport {

  var entityDao: EntityDao = _

  var syllabusService: SyllabusService = _

  def index(): View = {
    val today = LocalDate.now
    val query = OqlBuilder.from[Course](classOf[Clazz].getName, "c")
    query.join("c.teachers", "t")
    query.where("c.semester.endOn > :today", today)
    query.where("t.staff.code=:me", Securities.user)
    query.select("distinct c.course")
    query.orderBy("c.course.code")
    val activeCourses = entityDao.search(query)

    val query2 = OqlBuilder.from[Course](classOf[Clazz].getName, "c")
    query2.join("c.teachers", "t")
    query2.where("c.semester.endOn <= :today", today)
    query2.where("t.staff.code=:me", Securities.user)
    query2.select("distinct c.course")
    query2.orderBy("c.course.code")
    val hisCourses = Collections.newBuffer(entityDao.search(query2))
    hisCourses.subtractAll(activeCourses)

    val statHelper = new StatHelper(entityDao)
    val courses = activeCourses ++ hisCourses
    put("hasProfileCourses", statHelper.hasSyllabus(courses))
    put("hasSyllabusCourses", statHelper.hasProfile(courses))
    put("activeCourses", activeCourses)
    put("hisCourses", hisCourses)
    put("courses", courses)
    put("zh_template_url", getTemplateFile("zh.docx"))
    put("en_template_url", getTemplateFile("en.docx"))
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

  @mapping("{id}")
  def info(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    put("profile", getProfile(course))
    put("course", course)
    val docQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    docQuery.where("s.course = :course", course)
    docQuery.orderBy("s.semester.beginOn desc")
    put("syllabusDocs", entityDao.search(docQuery))

    val statHelper = new StatHelper(entityDao)
    put("clazzInfos", statHelper.statClazzInfo(course))
    forward()
  }

  @mapping(value = "{id}/edit")
  def edit(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    val profile = getProfile(course) match {
      case Some(p) => p
      case None => val cp = new CourseProfile
        cp.course = course
        cp
    }
    put("profile", profile)
    put("course", course)
    val syllabusQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    syllabusQuery.limit(1, 1)
    val writer = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    put("writer", writer)
    put("syllabusDocs", entityDao.search(syllabusQuery))
    put("Ems", Ems)
    forward()
  }

  private def getProfile(course: Course): Option[CourseProfile] = {
    val query = OqlBuilder.from(classOf[CourseProfile], "cp")
    query.where("cp.course = :course", course)
    entityDao.search(query).headOption
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
    profile.updatedAt = Instant.now
    val user = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    profile.writer = user
    entityDao.saveOrUpdate(profile)
    val course = entityDao.get(classOf[Course], profile.course.id)
    val parts = getAll("attachment", classOf[Part])
    val writerId = getLong("syllabusDoc.writer.id")
    if (parts.nonEmpty && parts.head.getSize > 0 && writerId.nonEmpty) {
      val part = parts.head
      val writer = entityDao.get(classOf[User], writerId.get)
      val syllabus = syllabusService.upload(course, writer, part.getInputStream,
        Strings.substringAfterLast(part.getSubmittedFileName, "."),
        Locale.SIMPLIFIED_CHINESE, Instant.now)
      syllabus.status = AuditStatus.Published
      entityDao.saveOrUpdate(syllabus)
    }
    redirect("index", "id=" + profile.course.id, "info.save.success")
  }

  @mapping(method = "post")
  def save(): View = {
    persist(populateEntity())
  }

  def attachment(): View = {
    val doc = entityDao.get(classOf[SyllabusDoc], getLongId("doc"))
    val path = EmsApp.getBlobRepository(true).url(doc.docPath)
    response.sendRedirect(path.get.toString)
    null
  }
}
