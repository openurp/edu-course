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
