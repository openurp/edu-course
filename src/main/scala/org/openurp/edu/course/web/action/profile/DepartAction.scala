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
import org.beangle.commons.activation.MediaTypes
import org.beangle.commons.file.zip.Zipper
import org.beangle.commons.io.{Files, IOs}
import org.beangle.commons.lang.Strings
import org.beangle.commons.logging.Logging
import org.beangle.commons.net.http.HttpUtils.followRedirect
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.{Ems, EmsApp}
import org.beangle.security.Securities
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.view.{Stream, View}
import org.openurp.base.edu.model.*
import org.openurp.base.model.{AuditStatus, Project, User}
import org.openurp.code.edu.model.{CourseCategory, CourseNature, CourseType}
import org.openurp.edu.course.model.{CourseTask, SyllabusDoc}
import org.openurp.edu.course.service.SyllabusService
import org.openurp.edu.course.web.helper.StatHelper
import org.openurp.starter.web.support.ProjectSupport

import java.io.{File, FileOutputStream, InputStream, OutputStream}
import java.net.URLConnection
import java.time.Instant
import java.util.Locale

class DepartAction extends ActionSupport, EntityAction[CourseTask], ProjectSupport, Logging {
  var entityDao: EntityDao = _
  var syllabusService: SyllabusService = _

  override def simpleEntityName: String = "task"

  def index(): View = {
    given project: Project = getProject

    put("courseTypes", getCodes(classOf[CourseType]))
    put("courseCategories", getCodes(classOf[CourseCategory]))
    put("courseNatures", getCodes(classOf[CourseNature]))
    put("teachingOffices", entityDao.getAll(classOf[TeachingOffice])) //FIXME for teachingGroup missing project
    put("departments", getDeparts)
    put("project", project)
    put("semester", getSemester)
    forward()
  }

  def search(): View = {
    val query = getQueryBuilder
    val tasks = entityDao.search(query)
    val courses = tasks.map(_.course).toSet
    val statHelper = new StatHelper(entityDao)
    put("hasProfileCourses", statHelper.hasProfile(courses))
    put("hasSyllabusCourses", statHelper.hasSyllabus(courses))
    put("tasks", tasks)
    forward()
  }

  protected override def getQueryBuilder: OqlBuilder[CourseTask] = {
    given project: Project = getProject

    val builder = super.getQueryBuilder
    builder.where("task.department in(:departs)", getDeparts)
    builder.where("task.course.project = :project", getProject)

    getBoolean("hasProfile") foreach {
      case true => builder.where("exists(from " + classOf[CourseProfile].getName + " clz where clz.course=course)")
      case false => builder.where("not exists(from " + classOf[CourseProfile].getName + " clz where clz.course=course)")
    }
    getBoolean("hasSyllabus") foreach {
      case true => builder.where("exists(from " + classOf[SyllabusDoc].getName + " clz where clz.course=course)")
      case false => builder.where("not exists(from " + classOf[SyllabusDoc].getName + " clz where clz.course=course)")
    }
    builder
  }

  @mapping(value = "{id}/edit")
  def edit(@param("id") id: String): View = {
    val task = entityDao.get(classOf[CourseTask], id.toLong)
    val course = task.course
    val profile = getProfile(course) match {
      case Some(p) => p
      case None => val cp = new CourseProfile
        cp.course = course
        cp
    }
    put("project", course.project)
    put("profile", profile)
    put("course", course)
    put("task", task)
    put("semester", task.semester)
    val syllabusQuery = OqlBuilder.from(classOf[SyllabusDoc], "s")
    syllabusQuery.where("s.course = :course", course)
    syllabusQuery.orderBy("s.semester.beginOn desc")
    syllabusQuery.limit(1, 1)
    put("syllabuses", entityDao.search(syllabusQuery))
    put("bookAdoptions", BookAdoption.values.map(x => (x.id, x.name)).toMap)
    put("Ems", Ems)
    forward()
  }

  @mapping(value = "{id}", method = "put")
  def update(@param("id") id: String): View = {
    val task = entityDao.get(classOf[CourseTask], id.toLong)
    val course = task.course
    val profile = getProfile(course).getOrElse(new CourseProfile)
    val user = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    profile.course = course
    if (null == profile.department) profile.department = course.department
    if (null == profile.semester) profile.semester = task.semester
    if (null == profile.beginOn) profile.beginOn = task.semester.beginOn
    populate(profile, "profile")
    profile.updatedAt = Instant.now
    profile.writer = user

    import org.openurp.base.edu.model.BookAdoption.{UseLecture, UseTextBook}
    profile.books.clear()
    profile.books.addAll(entityDao.find(classOf[Textbook], getLongIds("textbook")))
    if (profile.books.isEmpty) {
      if (profile.bookAdoption == UseTextBook) profile.bookAdoption = UseLecture
    } else {
      profile.bookAdoption = UseTextBook
    }
    entityDao.saveOrUpdate(profile)

    val parts = getAll("attachment", classOf[Part])
    val writerId = getLong("syllabusDoc.writer.id")
    if (parts.nonEmpty && parts.head.getSize > 0 && writerId.nonEmpty) {
      val part = parts.head
      val writer = entityDao.get(classOf[User], writerId.get)
      val syllabus = syllabusService.upload(course, writer, part.getInputStream,
        Strings.substringAfterLast(part.getSubmittedFileName, "."),
        Locale.SIMPLIFIED_CHINESE, task.semester)
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
    val doc = entityDao.get(classOf[SyllabusDoc], getLongId("doc"))
    val path = EmsApp.getBlobRepository(true).url(doc.docPath)
    response.sendRedirect(path.get.toString)
    null
  }

  def batchDownload(): View = {
    val taskIds = getLongIds("task")
    val courses = entityDao.find(classOf[CourseTask], taskIds).map(_.course)
    val query = OqlBuilder.from(classOf[SyllabusDoc], "s")
    query.where("s.course in(:courses)", courses)
    query.where("not exists(from " + classOf[SyllabusDoc].getName + " s2 where s2.course=s.course and s2.updatedAt>s.updatedAt)")
    val docs = entityDao.search(query)
    val departs = docs.map(_.course.department).distinct
    val dir = new File(System.getProperty("java.io.tmpdir") + "syllabus" + Files./ + System.currentTimeMillis())
    if (dir.exists()) Files.travel(dir, f => f.delete())
    dir.mkdirs()

    var paperCount = 0
    val blob = EmsApp.getBlobRepository(true)
    docs.foreach { doc =>
      blob.url(doc.docPath) foreach { url =>
        val courseName = doc.course.code // + " " + doc.course.name
        val fileName = dir.getAbsolutePath + Files./ + courseName + "." + Strings.substringAfterLast(doc.docPath, ".")
        downloading(url.openConnection(), new File(fileName))
        paperCount += 1
      }
    }
    val targetZip = new File(System.getProperty("java.io.tmpdir") + "syllabus" + Files./ + s"batch${System.currentTimeMillis()}.zip")
    logger.info(s"download to ${targetZip.getAbsolutePath}")
    Zipper.zip(dir, targetZip)
    val fileName = (if (departs.size == 1) then departs.head.name else departs.head.name + "等院系") + s"课程大纲(${paperCount}).zip"
    Stream(targetZip, MediaTypes.ApplicationZip, fileName).cleanup(() => {
      Files.travel(dir, f => f.delete())
      dir.delete()
      targetZip.delete()
    })
  }

  private def downloading(c: URLConnection, location: File): Unit = {
    val conn = followRedirect(c, "GET")
    var input: InputStream = null
    var output: OutputStream = null
    try {
      val file = new File(location.toString + ".part")
      file.delete()
      val buffer = Array.ofDim[Byte](1024 * 4)
      input = conn.getInputStream
      output = new FileOutputStream(file)
      var n = input.read(buffer)
      while (-1 != n) {
        output.write(buffer, 0, n)
        n = input.read(buffer)
      }
      //先关闭文件读写，再改名
      IOs.close(input, output)
      input = null
      output = null
      file.renameTo(location)
    } catch {
      case e: Throwable =>
        logger.warn(s"Cannot download file ${location}")
    }
    finally {
      IOs.close(input, output)
    }
  }
}
