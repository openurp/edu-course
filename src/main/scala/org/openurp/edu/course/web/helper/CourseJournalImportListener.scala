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

package org.openurp.edu.course.web.helper

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.doc.transfer.importer.{ImportListener, ImportResult}
import org.openurp.base.edu.model.{Course, CourseJournal, CourseJournalHour}
import org.openurp.base.std.model.Grade
import org.openurp.code.edu.model.{CourseTag, TeachingNature}

import java.time.Instant

class CourseJournalImportListener(entityDao: EntityDao, grade: Grade,
                                  natures: collection.Seq[TeachingNature], tags: collection.Seq[CourseTag])
  extends ImportListener {

  var hasNatureHours: Boolean = false

  override def onStart(tr: ImportResult): Unit = {
    natures.foreach { n =>
      if (tr.transfer.attrs.exists(_.name == s"hour${n.id}")) {
        hasNatureHours = true
      }
    }
  }

  override def onItemStart(tr: ImportResult): Unit = {
    transfer.curData.get("course.code") foreach { code =>
      entityDao.findBy(classOf[Course], "code" -> code, "project" -> grade.project).headOption match
        case None => tr.addFailure("找不到对应的课程", code)
        case Some(course) =>
          val query = OqlBuilder.from(classOf[CourseJournal], "ct")
          query.where("ct.beginOn=:beginOn", grade.beginOn)
          query.where("ct.course =:course", course)
          val journal = entityDao.search(query).headOption.getOrElse(new CourseJournal(course, grade.beginOn))
          transfer.current = journal
    }
  }

  override def onItemFinish(tr: ImportResult): Unit = {
    val journal = transfer.current.asInstanceOf[CourseJournal]
    if (journal.course == null) return

    if (hasNatureHours) {
      natures.foreach { n =>
        transfer.curData.get(s"hour${n.id}").asInstanceOf[Option[Int]] match
          case None => journal.hours.subtractAll(journal.hours.find(_.nature == n))
          case Some(h) =>
            journal.hours.find(_.nature == n) match
              case None => journal.hours.addOne(new CourseJournalHour(journal, n, h))
              case Some(jh) => jh.creditHours = h
      }
    }

    val jt = Collections.newSet[CourseTag]
    tags foreach { tag =>
      val c = transfer.curData.getOrElse(s"tag${tag.id}", "").toString
      if (c == "是" || c == "Y" || c == "y" || c == "1") {
        jt.addOne(tag)
      }
    }
    journal.tags.clear()
    journal.tags.addAll(jt)
    journal.updatedAt = Instant.now
    entityDao.saveOrUpdate(journal.course, journal)
  }

}
