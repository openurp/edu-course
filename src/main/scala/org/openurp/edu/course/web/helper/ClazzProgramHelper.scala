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

import org.beangle.commons.lang.Strings
import org.openurp.edu.course.model.{ClazzProgram, ShortInterval}
import org.openurp.edu.schedule.service.LessonSchedule

object ClazzProgramHelper {

  def updateStatInfo(p: ClazzProgram): Unit = {
    val clazz = p.clazz
    val schedules = LessonSchedule.convert(clazz)
    p.lessonCount = schedules.size.toShort
    p.designCount = p.designs.size.toShort
    p.designs foreach { d =>
      val s = schedules(d.idx - 1)
      d.creditHours = s.hours
      d.lessonOn = s.date
      val b = Strings.substringBefore(s.units, "-").toShort
      val e = Strings.substringAfter(s.units, "-").toShort
      d.units = ShortInterval(b, e)
    }
  }
}
