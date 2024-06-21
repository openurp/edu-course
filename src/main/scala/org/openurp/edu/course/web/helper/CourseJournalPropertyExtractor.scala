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

import org.beangle.commons.bean.DefaultPropertyExtractor
import org.beangle.commons.lang.Strings
import org.openurp.base.edu.model.CourseJournal

class CourseJournalPropertyExtractor extends DefaultPropertyExtractor {

  override def get(target: Object, property: String): Any = {
    val journal = target.asInstanceOf[CourseJournal]
    if (property.startsWith("hour.")) {
      val hid = Strings.substringAfter(property, "hour.")
      journal.hours.find(_.nature.id.toString == hid) match
        case None => ""
        case Some(h) => h.creditHours
    } else {
      super.get(target, property)
    }
  }
}
