[#ftl]
[@b.head/]
[@b.grid items=syllabuses var="syllabus"]
  [@b.gridbar]
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,course.name:课程名称,department.name:开课院系,"+
                "course.defaultCredits:学分,creditHours:学时,[#list teachingNatures as n]hour.${n.id}:${n.name},[/#list]"+
                "module.name:模块,"+
                "rank.name:必修选修,nature.name:课程性质,textbooks:教材,prerequisites:先修课程,"+
                "corequisites:并修课程,subsequents:后续课程",
                null,'fileName=课程大纲信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="课程代码"/]
    [@b.col property="course.name" title="课程名称"/]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${syllabus.department.shortName!syllabus.department.name}
    [/@]
    [@b.col width="10%" property="office.name" title="教研室"]
      <div class="text-ellipsis" title="负责人:${(syllabus.office.director.name)!}">${(syllabus.office.name)!}</div>
    [/@]
    [@b.col width="8%" property="writer.name" title="编写人"/]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="course.creditHours" title="学时"]
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
