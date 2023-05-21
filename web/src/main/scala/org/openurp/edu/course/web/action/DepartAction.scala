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

package org.openurp.edu.course.web.action

import jakarta.servlet.http.Part
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.data.model.Entity
import org.beangle.ems.app.{Ems, EmsApp}
import org.beangle.security.Securities
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.code.{CourseCategory, CourseType}
import org.openurp.base.edu.model.{Course, TeachingOffice}
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.base.profile.model.CourseProfile
import org.openurp.code.edu.model.CourseNature
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{Syllabus, SyllabusFile}
import org.openurp.edu.course.service.SyllabusService
import org.openurp.edu.course.web.helper.StatHelper
import org.openurp.starter.web.support.ProjectSupport

import java.time.{Instant, LocalDate}
import java.util.Locale

class DepartAction extends ActionSupport, EntityAction[Course], ProjectSupport {
  var entityDao: EntityDao = _
  var syllabusService: SyllabusService = _

  def index(): View = {
    given project: Project = getProject

    put("courseTypes", getCodes(classOf[CourseType]))
    put("courseCategories", getCodes(classOf[CourseCategory]))
    put("courseNatures", getCodes(classOf[CourseNature]))
    put("teachingOffices", entityDao.getAll(classOf[TeachingOffice])) //FIXME for teachingGroup missing project
    put("departments", getDeparts)
    put("project", getProject)
    forward()
  }

  def search(): View = {
    val query = getQueryBuilder
    val courses = entityDao.search(query)
    val statHelper = new StatHelper(entityDao)
    put("hasProfileCourses", statHelper.hasSyllabus(courses))
    put("hasSyllabusCourses", statHelper.hasProfile(courses))
    put("courses", courses)
    forward()
  }

  protected override def getQueryBuilder: OqlBuilder[Course] = {
    given project: Project = getProject

    val builder = super.getQueryBuilder
    builder.where("course.department in(:departs)", getDeparts)
    builder.where(simpleEntityName + ".project = :project", getProject)
    addTemporalOn(builder, Some(true))
    val hasClazz = getBoolean("hasClazz")
    val semesterId = getInt("semester.id")
    hasClazz foreach {
      case true =>
        semesterId match {
          case Some(sid) => builder.where("exists(from " + classOf[Clazz].getName + " clz where clz.course=course and clz.semester.id=:semesterId)", sid)
          case None => builder.where("exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
        }
      case false =>
        semesterId match {
          case Some(sid) => builder.where("not exists(from " + classOf[Clazz].getName + " clz where clz.course=course and clz.semester.id=:semesterId)", sid)
          case None => builder.where("not exists(from " + classOf[Clazz].getName + " clz where clz.course=course)")
        }
    }
    getBoolean("hasProfile") foreach {
      case true => builder.where("exists(from " + classOf[CourseProfile].getName + " clz where clz.course=course)")
      case false => builder.where("not exists(from " + classOf[CourseProfile].getName + " clz where clz.course=course)")
    }
    getBoolean("hasSyllabus") foreach {
      case true => builder.where("exists(from " + classOf[Syllabus].getName + " clz where clz.course=course)")
      case false => builder.where("not exists(from " + classOf[Syllabus].getName + " clz where clz.course=course)")
    }
    builder
  }

  private def addTemporalOn[T <: Entity[_]](builder: OqlBuilder[T], active: Option[Boolean]): OqlBuilder[T] = {
    active.foreach { active =>
      if (active) {
        builder.where(
          builder.alias + ".beginOn <= :now and (" + builder.alias + ".endOn is null or " + builder.alias + ".endOn >= :now)",
          LocalDate.now())
      } else {
        builder.where(
          "not (" + builder.alias + ".beginOn <= :now and (" + builder.alias + ".endOn is null or " + builder.alias + ".endOn >= :now))",
          LocalDate.now())
      }
    }
    builder
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
    put("syllabuses", entityDao.search(syllabusQuery))
    put("Ems", Ems)
    forward()
  }

  @mapping(value = "{id}", method = "put")
  def update(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    val profile = getProfile(course).getOrElse(new CourseProfile)
    val user = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    profile.course = course
    populate(profile, "profile")
    profile.updatedAt = Instant.now
    profile.updatedBy = user
    entityDao.saveOrUpdate(profile)

    val parts = getAll("attachment", classOf[Part])
    val authorId = getLong("syllabus.author.id")
    if (parts.size > 0 && parts.head.getSize > 0 && authorId.nonEmpty) {
      val part = parts.head
      val author = entityDao.get(classOf[User], authorId.get)
      val syllabus = syllabusService.upload(course, author, part.getInputStream,
        Strings.substringAfterLast(part.getSubmittedFileName, "."),
        Locale.SIMPLIFIED_CHINESE, Instant.now)
      syllabus.status = AuditStatus.Published
      entityDao.saveOrUpdate(syllabus)
    }
    redirect("search", "info.save.success")
  }

  private def getProfile(course: Course): Option[CourseProfile] = {
    val query = OqlBuilder.from(classOf[CourseProfile], "cp")
    query.where("cp.course = :course", course)
    entityDao.search(query).headOption
  }

  def attachment(): View = {
    val file = entityDao.get(classOf[SyllabusFile], getLongId("file"))
    val path = EmsApp.getBlobRepository(true).url(file.filePath)
    response.sendRedirect(path.get.toString)
    null
  }

}
