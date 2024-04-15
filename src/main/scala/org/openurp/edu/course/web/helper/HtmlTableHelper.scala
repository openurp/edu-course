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
