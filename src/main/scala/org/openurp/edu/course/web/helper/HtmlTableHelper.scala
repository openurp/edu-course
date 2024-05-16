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

object HtmlTableHelper {

  def cleanup(tableHtml: String): String = {
    var html = Strings.substringBetween(tableHtml, "<table", "</table>")
    if (Strings.isBlank(html)) {
      return tableHtml
    } else {
      html = "<table" + html + "</table>"
    }
    var m = Pattern.compile("<table.*?>(.*?)</table>", Pattern.MULTILINE | Pattern.DOTALL).matcher(html)
    var sb = new java.lang.StringBuilder()
    while (m.find()) {
      val inner = "<table border='1'>" + m.group(1) + "</table>"
      m.appendReplacement(sb, inner);
    }
    m.appendTail(sb)
    html = sb.toString

    m = Pattern.compile("<tr+.*?>(.*?)</tr>", Pattern.MULTILINE | Pattern.DOTALL).matcher(html)
    sb = new java.lang.StringBuilder();
    while (m.find()) {
      val inner = "<tr>" + m.group(1) + "</tr>"
      m.appendReplacement(sb, inner);
    }
    m.appendTail(sb)
    html = sb.toString

    m = Pattern.compile("<td+.*?>(.*?)</td>", Pattern.MULTILINE | Pattern.DOTALL).matcher(html)
    sb = new java.lang.StringBuilder();
    while (m.find()) {
      val inner = "<td>" + HtmlTextExtractor.extract(m.group()) + "</td>"
      m.appendReplacement(sb, inner);
    }
    m.appendTail(sb)

    sb.toString
  }
}
