/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.edu.course.web.action

import jakarta.servlet.http.Part
import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.{Ems, EmsApp}
import org.beangle.security.Securities
import org.beangle.webmvc.api.action.ServletSupport
import org.beangle.webmvc.api.annotation.{mapping, param}
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.EntityAction
import org.openurp.base.edu.model.Course
import org.openurp.base.model.User
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseProfile, Syllabus, SyllabusFile, SyllabusStatus}
import org.openurp.edu.course.service.SyllabusService
import org.openurp.edu.course.web.helper.StatHelper

import java.time.Instant
import java.util.Locale

class ReviseAction extends EntityAction[CourseProfile] with ServletSupport {

  var syllabusService: SyllabusService = _

  def index(): View = {
    val query = OqlBuilder.from[Course](classOf[Clazz].getName, "c")
    query.join("c.teachers", "t")
    query.where("t.user.code=:me", Securities.user)
    query.select("distinct c.course")
    query.orderBy("c.course.code")
    val courses = entityDao.search(query)
    val statHelper = new StatHelper(entityDao)
    put("hasProfileCourses", statHelper.hasSyllabus(courses))
    put("hasSyllabusCourses", statHelper.hasProfile(courses))
    put("courses", courses)
    forward()
  }

  @mapping("{id}")
  def info(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    put("profile", getProfile(course))
    put("course", course)
    val syllabusQuery = OqlBuilder.from(classOf[Syllabus], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    put("syllabuses", entityDao.search(syllabusQuery))

    val statHelper = new StatHelper(entityDao)
    put("clazzInfos", statHelper.statClazzInfo(course))
    forward()
  }

  private def getProfile(course: Course): Option[CourseProfile] = {
    val query = OqlBuilder.from(classOf[CourseProfile], "cp")
    query.where("cp.course = :course", course)
    entityDao.search(query).headOption
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
    val syllabusQuery = OqlBuilder.from(classOf[Syllabus], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    syllabusQuery.limit(1, 1)
    val author = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    put("author", author)
    put("syllabuses", entityDao.search(syllabusQuery))
    put("Ems", Ems)
    forward()
  }

  @mapping(value = "{id}", method = "put")
  def update(@param("id") id: String): View = {
    val entity = populate(getModel(id), entityName, simpleEntityName)
    persist(entity)
  }

  @mapping(method = "post")
  def save(): View = {
    persist(populateEntity())
  }

  override protected def simpleEntityName: String = {
    "profile"
  }

  def attachment(): View = {
    val file = entityDao.get(classOf[SyllabusFile], longId("file"))
    val path = EmsApp.getBlobRepository(true).url(file.filePath)
    response.sendRedirect(path.get.toString)
    null
  }

  def persist(profile: CourseProfile): View = {
    profile.updatedAt = Instant.now
    val user = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    profile.updatedBy = user
    entityDao.saveOrUpdate(profile)
    val course = entityDao.get(classOf[Course], profile.course.id)
    val parts = getAll("attachment", classOf[Part])
    val authorId = getLong("syllabus.author.id")
    if (parts.size > 0 && parts.head.getSize > 0 && authorId.nonEmpty) {
      val part = parts.head
      val author = entityDao.get(classOf[User], authorId.get)
      val syllabus = syllabusService.upload(course, author, part.getInputStream, part.getSubmittedFileName,
        Locale.SIMPLIFIED_CHINESE, Instant.now)
      syllabus.status = SyllabusStatus.Published
      entityDao.saveOrUpdate(syllabus)
    }
    redirect("index", "id=" + profile.course.id, "info.save.success")
  }
}
