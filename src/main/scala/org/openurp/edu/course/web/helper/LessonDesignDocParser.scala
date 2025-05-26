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
import org.beangle.doc.docx.DocParser
import org.beangle.doc.html.Dom
import org.beangle.doc.{docx, html}
import org.openurp.edu.course.model.{LessonDesign, LessonDesignSection, LessonDesignText}

import java.io.{FileInputStream, InputStream}
import scala.collection.mutable
import scala.jdk.javaapi.CollectionConverters.asScala

class LessonDesignDocParser {
  var doc: XWPFDocument = _
  var tables: mutable.Buffer[XWPFTable] = Collections.newBuffer[XWPFTable]
  val tmpDoc = new html.Document
  val parser = new DocParser(tmpDoc)
  var sectionIdx = 1

  def main(args: Array[String]): Unit = {
    val rs = parse(new FileInputStream("C:\\Users\\duantihua\\Desktop\\ja.docx"))
    println(rs._1)
    rs._1 foreach { d =>
      println(d.homework)
    }
  }

  def parse(is: InputStream): (Option[LessonDesign], Option[html.Document], String) = {
    doc = new XWPFDocument(is)
    tables = tables.addAll(asScala(doc.getTables))
    if (tables.nonEmpty) markUsed(tables.head) //去除第一个表格

    findProgramTable(doc) match
      case None => (None, None, "找不到教案所在的表格")
      case Some(table) =>
        markUsed(table)

        findSectionTitleRowIndex(table) match
          case None =>
            findSummaryDetailTable() match
              case None => (None, None, "找不到教学内容与过程设计")
              case Some(detailTable) =>
                markUsed(detailTable)
                val design = readDesign(table, Int.MaxValue)
                readSections(design, detailTable, 0) //第0行是教学内容与过程设计
                readRemindSections(design)
                (Some(design), Some(tmpDoc), "")
          case Some(row) =>
            val design = readDesign(table, row)
            readSections(design, table, row)
            readRemindSections(design)
            (Some(design), Some(tmpDoc), "")
  }

  private def readRemindSections(design: LessonDesign): Unit = {
    while (tables.nonEmpty) {
      val table = tables.head
      markUsed(table)
      readSections(design, table, -1)
    }
  }

  private def readDesign(table: XWPFTable, separatorIndex: Int): LessonDesign = {
    val ld = new LessonDesign()
    val rowIter = table.getRows.iterator()
    var i = 0

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
    while (rowIter.hasNext) {
      var row = rowIter.next()
      //从整个表的某个分界线（《教学内容与过程设计》）后，每三行作为一个section
      if (i > separatorIndex) {
        val sectionRows = Collections.newBuffer[XWPFTableRow]
        sectionRows.addOne(row)
        var fectched = 0
        while (rowIter.hasNext && fectched < 2) {
          fectched += 1
          row = rowIter.next()
          if (row.getTableCells.size() == 1) { // section中的后两个个元素都是独占一个格子的
            sectionRows.addOne(row)
          }
        }
        //过程设计没有在此表里，估计单独设表了,尝试取发现单独的表
        if (sectionRows.size == 2) {
          findDesignDetailTable(table) foreach { detailTable =>
            markUsed(detailTable)
            sectionRows.addOne(detailTable.getRow(0))
          }
        }
        if (sectionRows.size >= 2) {
          readSection(design, sectionIdx, sectionRows)
          sectionIdx += 1
        }
      }
      i += 1
    }
    //解析尾部设置的课后作业
    val lastRow = table.getRows.get(table.getRows.size() - 1)
    if (lastRow.getTableCells.size() == 2) {
      val title = lastRow.getCell(0).getText
      if title.contains("课后作业") then
        tmpDoc.body.children = Seq.empty
        parser.parse(lastRow.getTableCells.get(1).getBodyElements, tmpDoc.body)
        design.homework = Some(tmpDoc.body.innerHTML)
    }
  }

  private def readSection(design: LessonDesign, index: Int, sectionRows: mutable.Buffer[XWPFTableRow]): Unit = {
    val row1 = sectionRows.head
    val row2 = sectionRows(1)
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
    val body = tmpDoc.body
    body.children = Seq.empty

    parser.readStyles(row2.getTable.getBody.getXWPFDocument)
    parser.parse(row2.getTableCells.get(0).getBodyElements, body)
    body.children.find { x => x.isInstanceOf[Dom.P] && x.asInstanceOf[Dom.P].text.contains("教学内容提要") } foreach { p =>
      body.remove(p)
    }
    val summary = body.innerHTML

    var details = ""
    if (sectionRows.size == 3) {
      val row3 = sectionRows(2)
      body.children = Seq.empty
      parser.parse(row3.getTableCells.get(0).getBodyElements, body)

      body.children.find { x => x.isInstanceOf[Dom.P] && x.asInstanceOf[Dom.P].text.contains("教学过程设计") } foreach { p =>
        body.remove(p)
      }
      details = body.innerHTML
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

  /** 找到{教学内容与过程设计}所在行
   *
   * @param table
   * @return
   */
  private def findSectionTitleRowIndex(table: XWPFTable): Option[Int] = {
    val rs = asScala(table.getRows).find { r =>
      r.getTableCells.size == 1 && r.getTableCells.get(0).getText.contains("教学内容与过程设计")
    }
    rs.map { r => table.getRows.indexOf(r) }
  }

  private def markUsed(table: XWPFTable): Unit = {
    this.tables -= table
  }

  private def findProgramTable(document: XWPFDocument): Option[XWPFTable] = {
    tables.find { t =>
      if (t.getRows.size > 1 && t.getRows.get(0).getTableCells.size > 1) {
        t.getRows.get(0).getTableCells.get(0).getText.contains("教学主题")
      } else {
        false
      }
    }
  }

  /** 发现一个单独的表格，用于读取教学内容与过程设计
   * 一般这个表格不会独立出来。
   *
   * @param document
   * @return
   */
  private def findSummaryDetailTable(): Option[XWPFTable] = {
    tables.find { t =>
      if (t.getRows.size > 1 && t.getRows.get(0).getTableCells.size > 0) {
        t.getRows.get(0).getTableCells.get(0).getText.contains("教学内容与过程设计")
      } else {
        false
      }
    }
  }

  /** 从某个表格之后查找单独的《教学过程设计》表格
   *
   * @param document
   * @param after
   * @return
   */
  private def findDesignDetailTable(after: XWPFTable): Option[XWPFTable] = {
    val idx = tables.indexOf(after)
    this.tables = tables.takeRight(tables.size - idx - 1)
    this.tables.find { t =>
      if (t.getRows.size > 0 && t.getRows.get(0).getTableCells.size > 0) {
        t.getRows.get(0).getTableCells.get(0).getText.contains("教学过程设计")
      } else {
        false
      }
    }
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
