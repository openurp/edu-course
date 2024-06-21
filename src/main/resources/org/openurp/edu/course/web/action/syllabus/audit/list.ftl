[#ftl]
[@b.head/]
[@b.grid items=syllabuses var="syllabus"]
  [@b.gridbar]
    bar.addItem("审核通过",action.multi("audit","确认审核通过?","passed=1"));
    bar.addItem("驳回修改",action.multi("audit","确认驳回修改?","passed=0"));
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,course.name:课程名称,department.name:开课院系,writer.name:编写人,"+
                "course.defaultCredits:学分,creditHours:学时,[#list teachingNatures as n]hour.${n.id}:${n.name},[/#list]"+
                "examCreditHours:期末考核学时,learningHours:自主学习学时,stage.name:学期阶段,module.name:模块,"+
                "rank.name:必修选修,nature.name:课程性质,examMode.name:考核方式,"+
                "assessment.usual_percent:平时成绩百分比,assessment.usual_percents:过程性考核百分比,assessment.end_percent:期末成绩百分比,"+
                "status:状态",
                null,'fileName=课程大纲信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="课程代码"/]
    [@b.col width="20%" property="course.name" title="课程名称"]
      [@b.a href="!info?id="+syllabus.id target="_blank"]${syllabus.course.name}[/@]
    [/@]
    [@b.col width="5%" property="locale" title="语言"]
      ${locales.get(syllabus.locale)}
    [/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${syllabus.department.shortName!syllabus.department.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
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
