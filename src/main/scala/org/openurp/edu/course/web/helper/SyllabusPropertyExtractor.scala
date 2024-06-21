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
import org.openurp.code.edu.model.GradeType
import org.openurp.edu.course.model.Syllabus

class SyllabusPropertyExtractor extends DefaultPropertyExtractor {

  override def get(target: Object, property: String): Any = {
    val syllabus = target.asInstanceOf[Syllabus]
    if (property.startsWith("assessment.")) {
      val p = Strings.substringAfter(property, "assessment.")
      if (p == "usual_percent") {
        syllabus.getAssessment(new GradeType(GradeType.Usual), null) match
          case None => ""
          case Some(a) => a.scorePercent + "%"
      } else if (p == "end_percent") {
        syllabus.getAssessment(new GradeType(GradeType.End), null) match
          case None => ""
          case Some(a) => a.scorePercent + "%"
      } else if (p == "usual_percents") {
        syllabus.getAssessment(new GradeType(GradeType.Usual), null) match
          case None => ""
          case Some(a) =>
            val components = syllabus.assessments.filter(x => x.gradeType.id == GradeType.Usual && x.component.nonEmpty).sortBy(_.idx)
            components.map(x => x.component.get + " " + x.scorePercent + "%").mkString(",")
      }else{
        ""
      }
    } else if (property.startsWith("hour.")) {
      val natureId = Strings.substringAfter(property, "hour.")
      syllabus.hours.find(x => x.nature.id.toString == natureId) match
        case None => ""
        case Some(h) => h.creditHours
    }
    else super.get(target, property)
  }
}
