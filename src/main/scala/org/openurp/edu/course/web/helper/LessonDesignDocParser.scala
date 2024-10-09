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

import org.apache.poi.xwpf.usermodel.*
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.{Numbers, Strings}
import org.openurp.edu.course.model.{LessonDesign, LessonDesignSection, LessonDesignText}

import java.io.{FileInputStream, InputStream}
import scala.collection.mutable
import scala.jdk.javaapi.CollectionConverters.asScala

object LessonDesignDocParser {

  def main(args: Array[String]): Unit = {
    val rs = parse(new FileInputStream("C:\\Users\\duantihua\\Desktop\\ja.docx"))
    println(rs._1)
    rs._1 foreach { d =>
      println(d.homework)
    }
  }

  def parse(is: InputStream): (Option[LessonDesign], String) = {
    val doc = new XWPFDocument(is)
    findProgramTable(doc) match
      case None => (None, "找不到教案所在的表格")
      case Some(table) =>
        findSectionTitleRowIndex(table) match
          case None =>
            findDetailTable(doc) match
              case None => (None, "找不到教学内容与过程设计")
              case Some(detailTable) =>
                val design = readDesign(table, Int.MaxValue)
                readSections(design, detailTable, 0)
                (Some(design), "")
          case Some(row) =>
            val design = readDesign(table, row)
            readSections(design, table, row)
            (Some(design), "")
  }

  private def readDesign(table: XWPFTable, separatorIndex: Int): LessonDesign = {
    val ld = new LessonDesign()
    val rowIter = table.getRows.iterator()
    var i = 0
    var sectionIdx = 1
    while (rowIter.hasNext) {
      val row = rowIter.next()
      if (i < separatorIndex) {
        val title = row.getTableCells.get(0).getText
        if (title.contains("教学主题")) {
          ld.subject = readCell(row.getTableCells.get(1))
        } else {
          readText(title, row.getTableCells.get(1), ld)
        }
      }
      i += 1
    }
    ld
  }

  private def readSections(design: LessonDesign, table: XWPFTable, separatorIndex: Int): Unit = {
    val rowIter = table.getRows.iterator()
    var i = 0
    var sectionIdx = 1
    while (rowIter.hasNext) {
      val row = rowIter.next()
      if (i > separatorIndex) {
        val sectionRows = Collections.newBuffer[XWPFTableRow]
        sectionRows.addOne(row)
        var fectched = 0
        while (rowIter.hasNext && fectched < 2) {
          fectched += 1
          sectionRows.addOne(rowIter.next())
        }
        if (sectionRows.size == 3) {
          readSection(design, sectionIdx, sectionRows)
          sectionIdx += 1
        } else {
          val title = row.getTableCells.get(0).getText
          if title.contains("课后作业") then design.homework = Some(readCell(row.getTableCells.get(1)))
        }
      }
      i += 1
    }
  }

  private def readSection(design: LessonDesign, index: Int, sectionRows: mutable.Buffer[XWPFTableRow]): Unit = {
    val row1 = sectionRows.head
    val row2 = sectionRows(1)
    val row3 = sectionRows(2)
    var title = readCell(row1.getTableCells.get(0))
    seqIndices.find(x => index < x.length && title.startsWith(x(index - 1))) foreach { seq =>
      title = title.substring(seq(index - 1).length + 1)
    }
    var duration = if (row1.getTableCells.size() > 1) readCell(row1.getTableCells.get(1)) else ""
    duration = Strings.replace(duration, "分钟", "").trim
    var minutes = 0
    if (Numbers.isDigits(duration)) {
      minutes = duration.toInt
    }
    var summary = readCell2Html(row2.getTableCells.get(0))
    if (summary.contains("教学内容提要")) {
      summary = summary.replaceAll("<p>(.*?)教学内容提要(.*?)</p>","")
    }
    var details = readCell2Html(row3.getTableCells.get(0))
    if (details.contains("教学过程设计")) {
      details = details.replaceAll("<p>(.*?)教学过程设计（包括教学方法与手段(.*?)</p>","")
    }
    val section = new LessonDesignSection(design, index, title, minutes, summary, details)
    design.sections.addOne(section)
  }

  private def readText(title: String, cell: XWPFTableCell, design: LessonDesign): Unit = {
    val contents = readCell(cell)
    if (Strings.isNotBlank(contents)) {
      if (title.contains("教学目标")) {
        design.texts.addOne(new LessonDesignText(design, "target", contents))
      } else if (title.contains("教学重点")) {
        design.texts.addOne(new LessonDesignText(design, "emphasis", contents))
      } else if (title.contains("教学难点")) {
        design.texts.addOne(new LessonDesignText(design, "difficulties", contents))
      } else if (title.contains("教学资源")) {
        design.texts.addOne(new LessonDesignText(design, "resources", contents))
      } else if (title.contains("课程思政")) {
        design.texts.addOne(new LessonDesignText(design, "values", contents))
      }
    }
  }

  private def findSectionTitleRowIndex(table: XWPFTable): Option[Int] = {
    val rs = asScala(table.getRows).find { r =>
      r.getTableCells.size == 1 && r.getTableCells.get(0).getText.contains("教学内容与过程设计")
    }
    rs.map { r => table.getRows.indexOf(r) }
  }

  private def findProgramTable(document: XWPFDocument): Option[XWPFTable] = {
    asScala(document.getTables).find { t =>
      if (t.getRows.size > 1 && t.getRows.get(0).getTableCells.size > 1) {
        t.getRows.get(0).getTableCells.get(0).getText.contains("教学主题")
      } else {
        false
      }
    }
  }

  private def findDetailTable(document: XWPFDocument): Option[XWPFTable] = {
    asScala(document.getTables).find { t =>
      if (t.getRows.size > 1 && t.getRows.get(0).getTableCells.size > 0) {
        t.getRows.get(0).getTableCells.get(0).getText.contains("教学内容与过程设计")
      } else {
        false
      }
    }
  }

  private def readCell2Html(cell: XWPFTableCell):String={
    val sb = new StringBuilder()
    for (p <- asScala(cell.getParagraphs)) {
      sb.append(DocParser.parse(p))
    }
    sb.toString
  }

  private def readCell(cell: XWPFTableCell): String = {
    val sb = new StringBuilder()
    for (p <- asScala(cell.getParagraphs)) {
      for (run <- asScala(p.getRuns)) {
        val runText = run.getText(0)
        if (Strings.isNotBlank(runText)) sb.append(runText)
      }
      sb.append("\n")
    }
    sb.toString.replace("\r", "").trim
  }

  private val seqIndices: Seq[Array[String]] =
    Seq(Array("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"),
      Array("一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五"),
      Array("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV"),
    )
}
