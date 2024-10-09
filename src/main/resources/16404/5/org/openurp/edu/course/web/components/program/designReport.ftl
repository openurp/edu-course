[@b.head loadui=false smallText=false/]
  [#assign program = design.program/]
  [#assign indexNames= ["一","二","三","四","五","六","七","八","九","十","十一","十二","十三","十四","十五"] /]
 [#include "designStyle.ftl" /]
[#macro multi_line_p contents=""]
  [#assign cnts]${contents!}[#nested/][/#assign]
  [#if cnts?length>0]
    [#assign ps = cnts?split("\n")]
    [#list ps as p]
    <p>${p}</p>
    [/#list]
  [/#if]
[/#macro]
[#macro display contents=""]
  [#assign cnts]${contents!}[#nested/][/#assign]
  [#if cnts?contains("</p>")]
    ${cnts}
  [#else]
    [@multi_line_p cnts/]
  [/#if]
[/#macro]
<div class="container">
  [#include "cover.ftl" /]
  <p style="page-break-before:always;font-family:黑体;font-size:20pt;text-align:center;">《${clazz.course.name}》教案</p>
  <p style="text-align:center;">第${design.idx}周，第${design.idx}次课，共${design.creditHours}课时</p>
  <table class="grid-table">
    <colgroup>
      <col width="20%"/>
      <col width="60%"/>
      <col width="20%"/>
    </colgroup>
    <tr><td class="title">教学主题</td><td colspan="2">${design.subject}</td></tr>
    <tr><td class="title">教学目标</td><td colspan="2">[@multi_line_p design.get('target')!/]</td></tr>
    <tr><td class="title">教学重点</td><td colspan="2">[@multi_line_p design.get('emphasis')!/]</td></tr>
    <tr><td class="title">教学难点</td><td colspan="2">[@multi_line_p design.get('difficulties')!/]</td></tr>
    <tr><td class="title">教学资源</td><td colspan="2">[@multi_line_p design.get('resources')!/]</td></tr>
    <tr><td class="title">课程思政融入点</td><td colspan="2">[@multi_line_p design.get('values')!/]</td></tr>

    <tr><td colspan="3" class="title">教学内容与过程设计</td></tr>
    [#list design.sections?sort_by("idx") as section]
    <tr>
      <td colspan="2" class="title-left">${indexNames[section.idx-1]}、${section.title}</td>
      <td class="title">${section.duration}分钟</td>
    </tr>
    <tr>
      <td colspan="3"><span class="title-left">教学内容提要：</span><br>
      [@display section.summary/]
      </td>
    </tr>
    <tr>
      <td colspan="3"><span class="title-left">教学过程设计（包括教学方法与手段、学生学习活动、教师支持活动等）：</span><br>
      [@display section.details/]
      </td>
    </tr>
    [/#list]

    <tr><td>课后作业</td><td colspan="2">[@multi_line_p design.homework/]</td></tr>
  </table>
</div>
[@b.foot/]
