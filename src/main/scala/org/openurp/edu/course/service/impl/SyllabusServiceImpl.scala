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
import org.beangle.data.model.pojo.TemporalOn
import org.beangle.ems.app.EmsApp
import org.openurp.base.edu.model.Course
import org.openurp.base.model.{Semester, User}
import org.openurp.base.service.SemesterService
import org.openurp.edu.course.model.SyllabusDoc
import org.openurp.edu.course.service.SyllabusService

import java.io.InputStream
import java.time.Instant
import java.util.Locale

class SyllabusServiceImpl extends SyllabusService {
  var semesterService: SemesterService = _
  var entityDao: EntityDao = _

  var validateYears = 4

  override def upload(course: Course, writer: User, data: InputStream, extension: String, locale: Locale, semester: Semester): SyllabusDoc = {
    val blob = EmsApp.getBlobRepository(true)
    val existed = getLastSyllabusDoc(course, locale, writer)
    val doc = existed.getOrElse(new SyllabusDoc)
    doc.course = course
    doc.updatedAt = Instant.now
    doc.writer = writer
    doc.docLocale = locale
    doc.department = course.department
    doc.semester = semester
    if (doc.beginOn == null) {
      doc.beginOn = semester.beginOn
    }
    if (doc.docPath != null) {
      blob.remove(doc.docPath)
    }
    val fileName = course.code + "大纲." + extension
    val meta = blob.upload(s"/course/${course.id}/syllabus/${writer.id}_${doc.beginOn.toString}/",
      data, fileName, writer.code + " " + writer.name)

    doc.docSize = meta.fileSize
    doc.docPath = meta.filePath
    entityDao.saveOrUpdate(doc)
    val docs = entityDao.findBy(classOf[SyllabusDoc], "course", course)
    TemporalOn.calcEndOn(docs)
    entityDao.saveOrUpdate(docs)
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
