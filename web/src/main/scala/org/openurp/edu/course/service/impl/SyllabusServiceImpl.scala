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
package org.openurp.edu.course.service.impl

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.EmsApp
import org.openurp.base.edu.model.Course
import org.openurp.base.edu.service.SemesterService
import org.openurp.base.model.User
import org.openurp.edu.course.model.{Syllabus, SyllabusFile}
import org.openurp.edu.course.service.SyllabusService

import java.io.InputStream
import java.time.{Instant, ZoneId}
import java.util.Locale

class SyllabusServiceImpl extends SyllabusService {
  var semesterService: SemesterService = _
  var entityDao: EntityDao = _

  var validateYears = 4

  override def upload(course: Course, author: User, data: InputStream, extension: String, locale: Locale, updatedAt: Instant): Syllabus = {
    val blob = EmsApp.getBlobRepository(true)

    val today = updatedAt.atZone(ZoneId.systemDefault()).toLocalDate
    val existed = getLastSyllabus(course, author)
    val syllabus = existed.getOrElse(new Syllabus)
    syllabus.course = course
    syllabus.updatedAt = updatedAt
    syllabus.author = author
    syllabus.department = course.department
    syllabus.semester = semesterService.get(course.project, today).get
    if (syllabus.beginOn == null) {
      syllabus.beginOn = today
    }
    syllabus.endOn = today.plusYears(validateYears)
    entityDao.saveOrUpdate(syllabus)

    if (syllabus.attachments.nonEmpty) {
      syllabus.attachments.find(x => x.docLocale == locale) foreach { removed =>
        syllabus.attachments -= removed
        blob.remove(removed.filePath)
      }
    }

    val fileName = course.name + "大纲." + extension
    val meta = blob.upload(s"/${course.id}/syllabus/${author.id}_${today.toString}/",
      data, fileName, author.code + " " + author.name)

    val attachment = new SyllabusFile
    attachment.fileSize = meta.fileSize
    attachment.mimeType = meta.mediaType
    attachment.docLocale = locale
    attachment.filePath = meta.filePath
    attachment.syllabus = syllabus
    syllabus.attachments += attachment

    entityDao.saveOrUpdate(syllabus, attachment)

    syllabus
  }

  private def getLastSyllabus(course: Course, author: User): Option[Syllabus] = {
    val query = OqlBuilder.from(classOf[Syllabus], "s")
    query.where("s.course = :course", course)
    query.where("s.author=:author", author)
    query.orderBy("s.semester.beginOn desc")
    query.limit(1, 1)
    entityDao.search(query).headOption
  }
}
