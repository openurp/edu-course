[#ftl]
[@b.head/]
[@b.grid items=courses var="course"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="code" title="代码"/]
    [@b.col width="20%" property="name" title="名称"][@b.a href="info!info?id=${course.id}" target="_blank"]${course.name}[/@][/@]
    [@b.col width="5%" property="credits" title="学分"/]
    [@b.col width="10%" property="creditHours" title="学时"]
      ${course.creditHours}
      [#if course.hours?size>1]
        ([#list course.hours?sort_by(['teachingNature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="5%" property="weekHours" title="周课时"/]
    [@b.col width="5%" property="weeks" title="周数"/]
    [@b.col width="20%" property="courseType.name" title="课程类型"/]
    [@b.col width="10%" property="examMode.name" title="考核方式"/]
    [@b.col width="15%" title="简介/大纲"]
      [@b.a href="!edit?id="+course.id][#if hasProfileCourses?seq_contains(course.id)]有[#else]--[/#if]/[#if hasSyllabusCourses?seq_contains(course.id)]有[#else]--[/#if][/@]
    [/@]
  [/@]
  [/@]
[@b.foot/]
