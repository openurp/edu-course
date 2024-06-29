[#ftl]
[@b.head/]
[@b.grid items=syllabuses var="syllabus"]
  [@b.gridbar]
    bar.addItem("审核通过",action.multi("audit","确认审核通过?","passed=1"));
    bar.addItem("驳回修改",action.multi("audit","确认驳回修改?","passed=0"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col width="20%" property="course.name" title="名称"]
      [@b.a href="!info?id="+syllabus.id target="_blank"]${syllabus.course.name}[/@]
    [/@]
    [@b.col width="5%" property="locale" title="语言"]
      ${locales.get(syllabus.docLocale)}
    [/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${syllabus.department.shortName!syllabus.department.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="syllabus.course.creditHours" title="学时"]
      ${syllabus.course.creditHours}
      [#if syllabus.hours?size>1]
        ([#list syllabus.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="6%" property="rank.name" title="必修选修"/]
    [@b.col width="7%" property="nature.name" title="课程性质"/]
    [@b.col width="8%" property="examMode.name" title="考核方式"/]
    [@b.col width="10%" property="status" title="状态"/]
  [/@]
  [/@]
[@b.foot/]
