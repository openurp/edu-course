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

import java.util.regex.Pattern

object HtmlTextExtractor {

  def extract(html: String): String = {
    var result = html
    result = Strings.replace(result, "\r", "")
    result = Strings.replace(result, "\n", "")
    result = Strings.replace(result, "</p>", "\n")
    result = Strings.replace(result, "<br/>", "\n")
    result = Strings.replace(result, "</div>", "\n")
    result = Strings.replace(result, "\t", " ")
    result = Strings.replace(result, "\u00A0", " ")
    result = Strings.replace(result, "\u3000", " ")
    result = Strings.replace(result, "&nbsp;", " ")

    val p = Pattern.compile( "<[a-zA-Z]+.*?>|<\\/[a-zA-Z ]*?>|<[a-zA-Z]+\\s\\/>")
    var m = p.matcher(result)

    while (m.find) {
      result = m.replaceAll("")
      m = p.matcher(result)
    }
    result.strip()
  }

  def stripLeading(s: String, removed: Set[Char]): String = {
    val chars = s.toCharArray
    var i = 0
    var breaking = false
    while (i < chars.length && !breaking) {
      val c = chars(i)
      if (Character.isWhitespace(c) || removed.contains(c)) {
        i += 1
      } else {
        breaking = true
      }
    }
    if i == 0 then s else s.substring(i)
  }
}
