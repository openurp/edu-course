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
import org.beangle.data.dao.EntityDao
import org.openurp.code.edu.model.GradeType
import org.openurp.edu.course.model.Syllabus

import java.util.Locale

class SyllabusHelper(entityDao: EntityDao) {

  def collectDatas(syllabus: Syllabus): collection.Map[String, Any] = {
    val datas = Collections.newMap[String, Any]
    datas.put("syllabus", syllabus)
    datas.put("usualType", entityDao.get(classOf[GradeType], GradeType.Usual))
    datas.put("endType", entityDao.get(classOf[GradeType], GradeType.End))
    datas.put("locales", Map(new Locale("zh", "CN") -> "中文", new Locale("en", "US") -> "English"))
    datas
  }
}
