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

import org.apache.poi.xwpf.usermodel.XWPFParagraph
import org.beangle.commons.lang.Strings
import org.beangle.doc.html.dom.{P, Span}

import scala.jdk.javaapi.CollectionConverters.asScala

object DocParser {

  def parse(paragrah:XWPFParagraph):P={
    val p = new P
    println(paragrah.getStyle)
    for (run <- asScala(paragrah.getRuns)) {
      val runText = run.getText(0)
      if (Strings.isNotEmpty(runText)) {
        val span = new Span
//        span.add()
//        p.add(runText)
      }
    }
    p
  }
}
