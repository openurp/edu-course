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

package org.openurp.edu.course.service.impl

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.EmsApp
import org.openurp.base.edu.model.{Course, CourseDirector, TeachingOffice}
import org.openurp.base.hr.model.Teacher
import org.openurp.base.model.{Department, Semester, User}
import org.openurp.base.service.SemesterService
import org.openurp.edu.course.model.{CourseTask, SyllabusDoc}
import org.openurp.edu.course.service.SyllabusService

import java.io.InputStream
import java.time.{Instant, ZoneId}
import java.util.Locale

class SyllabusServiceImpl extends SyllabusService {
  var semesterService: SemesterService = _
  var entityDao: EntityDao = _

  var validateYears = 4

  override def upload(course: Course, writer: User, data: InputStream, extension: String, locale: Locale, updatedAt: Instant): SyllabusDoc = {
    val blob = EmsApp.getBlobRepository(true)

    val today = updatedAt.atZone(ZoneId.systemDefault()).toLocalDate
    val existed = getLastSyllabusDoc(course, locale, writer)
    val doc = existed.getOrElse(new SyllabusDoc)
    doc.course = course
    doc.updatedAt = updatedAt
    doc.writer = writer
    doc.docLocale = locale
    doc.department = course.department
    doc.semester = semesterService.get(course.project, today)
    if (doc.beginOn == null) {
      doc.beginOn = today
    }
    doc.endOn = Some(today.plusYears(validateYears))
    if (doc.docPath != null) {
      blob.remove(doc.docPath)
    }
    val fileName = course.code + "大纲." + extension
    val meta = blob.upload(s"/course/${course.id}/syllabus/${writer.id}_${today.toString}/",
      data, fileName, writer.code + " " + writer.name)

    doc.docSize = meta.fileSize
    doc.docPath = meta.filePath
    entityDao.saveOrUpdate(doc)
    doc
  }

  private def getLastSyllabusDoc(course: Course, locale: Locale, writer: User): Option[SyllabusDoc] = {
    val query = OqlBuilder.from(classOf[SyllabusDoc], "s")
    query.where("s.course = :course", course)
    query.where("s.writer=:writer", writer)
    query.where("s.docLocale=:locale", locale)
    query.orderBy("s.semester.beginOn desc")
    query.limit(1, 1)
    entityDao.search(query).headOption
  }
}
