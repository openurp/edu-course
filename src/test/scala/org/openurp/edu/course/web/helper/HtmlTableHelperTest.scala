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

object HtmlTableHelperTest {

  def main(args: Array[String]): Unit = {
    val htmlStr =
      """
        |<table class="MsoTableGrid" border="1" cellspacing="0" style="border-collapse:collapse;border:none;">
        |  <tbody>
        |    <tr>
        |      <td width="241" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <b><span style="font-family:宋体;font-size:12.0000pt;"><span>项目</span></span></b><b><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span></b>
        |        </p>
        |      </td>
        |      <td width="737" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <b><span style="font-family:宋体;font-size:12.0000pt;"><span>评分要素</span></span></b><b><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span></b>
        |        </p>
        |      </td>
        |      <td width="157" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <b><span style="font-family:宋体;font-size:12.0000pt;"><span>满分</span></span></b><b><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span></b>
        |        </p>
        |      </td>
        |    </tr>
        |    <tr>
        |      <td width="241" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人选题与设计</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="737" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" style="text-indent:0.0000pt;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人选题与设计体现</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">R</span><span style="font-family:宋体;font-size:12.0000pt;"><span>PA</span><span>的优势，具有一定的实用价值。一般：</span><span>2</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">1</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">24</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；较好：</span><span>2</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">5</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">27</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；好：</span><span>2</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">8</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">30</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="157" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>3</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">0</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |    </tr>
        |    <tr>
        |      <td width="241" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人开发</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="737" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" style="text-indent:0.0000pt;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人功能完整，运用</span><span>UiBot</span><span>的多个功能，运行流畅。简单：</span><span>3</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">5</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">39</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；一般：</span><span>4</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">0</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">44</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；复杂：</span><span>4</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">5</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">50</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="157" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>5</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">0</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |    </tr>
        |    <tr>
        |      <td width="241" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人说明书</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="737" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" style="text-indent:0.0000pt;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人说明书内容完整，能反映机器人设计与开发的全过程。简单：</span><span>1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">0</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">2</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；较好：</span><span>1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">3</span><span style="font-family:宋体;font-size:12.0000pt;"><span>-1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">4</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；好：</span><span>1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">5</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="157" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>1</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">5</span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |    </tr>
        |    <tr>
        |      <td width="241" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人视频</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="737" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" style="text-indent:0.0000pt;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>机器人视频能反映机器人运行的全过程。一般：</span><span>1-</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;">2</span><span style="font-family:宋体;font-size:12.0000pt;"><span>；较好：</span><span>3-4</span><span>；好：</span><span>5</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |      <td width="157" valign="top" style="border:1.0000pt solid windowtext;">
        |        <p class="MsoNormal" align="center" style="text-indent:0.0000pt;text-align:center;">
        |          <span style="font-family:宋体;font-size:12.0000pt;"><span>5</span></span><span style="font-family:'Times New Roman';font-size:12.0000pt;"></span>
        |        </p>
        |      </td>
        |    </tr>
        |  </tbody>
        |</table>
        |<br />
        |""".stripMargin

    val html = HtmlTableHelper.cleanup(htmlStr)
    println(html)

  }
}
