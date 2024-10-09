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

import org.apache.poi.xwpf.usermodel.{ParagraphAlignment, UnderlinePatterns, XWPFParagraph}
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.openxmlformats.schemas.officeDocument.x2006.sharedTypes.STVerticalAlignRun

import java.util.Locale
import scala.jdk.javaapi.CollectionConverters.asScala

object DocParser {

  def parse(p: XWPFParagraph): String = {
    val sb = new StringBuilder()
    val styles = Collections.newMap[String, String]
    if (p.getIndentationLeft > 0) {
      styles.addOne("margin-left", s"${twipsToPoint(p.getIndentationLeft)}pt")
    }
    if (p.getIndentationFirstLine > 0) {
      styles.addOne("text-indent", s"${twipsToPoint(p.getIndentationFirstLine)}pt")
    }
    val align = p.getAlignment
    if (null != align && align != ParagraphAlignment.LEFT) {
      val alignStyle = align match {
        case ParagraphAlignment.RIGHT => "right"
        case ParagraphAlignment.CENTER => "center"
        case ParagraphAlignment.BOTH => "justify"
        case _ => "left"
      }
      if (alignStyle != "left")
        styles.addOne("text-align", alignStyle)
    }
    if (styles.nonEmpty) {
      sb.append(s"<p style='${styles.map(x => s"${x._1}:${x._2}").mkString(";")}'>")
    } else {
      sb.append(s"<p>")
    }
    for (run <- asScala(p.getRuns)) {
      var t = run.getText(0)
      if (Strings.isNotBlank(t)) {
        run.getVerticalAlignment match {
          case STVerticalAlignRun.SUPERSCRIPT => t = s"<sup>${t}</sup>"
          case STVerticalAlignRun.SUBSCRIPT => t = s"<sub>${t}</sub>"
          case _ =>
        }
        if (run.isStrikeThrough) t = s"<del>${t}</del>"
        if (run.isBold) t = s"<strong>${t}</strong>"
        if (run.isItalic) t = s"<em>${t}</em>"
        //FIXME 下划线很多种
        if (UnderlinePatterns.NONE != run.getUnderline) t = s"<u>${t}</u>"
        sb.append(Strings.replace(t, " ", "&nbsp;"))
      } else {
        sb.append(Strings.replace(t, " ", "&nbsp;"))
      }
    }
    sb.append("</p>")
    sb.mkString.replace("\r", "")
  }

  private def twipsToPoint(twips: Int): Int = {
    twips / 20
  }

}
