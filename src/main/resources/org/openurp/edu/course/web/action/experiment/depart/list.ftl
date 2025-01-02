[#ftl]
[@b.head/]
[@b.grid items=experiments var="experiment"]
  [@b.gridbar]
    bar.addItem("未设立实验课程",withoutExperiment);
    function withoutExperiment(){
      bg.form.submit(document.searchForm,"${b.url('none-exp')}","_blank");
    }
    bar.addItem("${b.text("action.export")}",
                action.exportData("syllabus.course.code:课程代码,syllabus.course.name:课程名称,syllabus.department.name:开课院系,"+
                "syllabus.course.defaultCredits:学分,syllabus.creditHours:学时,[#list teachingNatures as n]hour.${n.id}:${n.name},[/#list]"+
                "syllabus.module.name:模块,"+
                "syllabus.rank.name:必修选修,syllabus.nature.name:课程性质,textbooks:教材,syllabus.prerequisites:先修课程,"+
                "syllabus.corequisites:并修课程,syllabus.subsequents:后续课程,name:实验项目,"+
                "experimentType.name:实验类型,online:是否线上教学",
                null,'fileName=课程实验项目信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="syllabus.course.code" title="课程代码"/]
    [@b.col width="20%" property="syllabus.course.name" title="课程名称"/]
    [@b.col width="8%" property="syllabus.department.name" title="开课院系"]
      ${experiment.syllabus.department.shortName!experiment.department.name}
    [/@]
    [@b.col width="5%" property="syllabus.course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="syllabus.course.creditHours" title="学时"]
      ${experiment.syllabus.course.creditHours}
      [#if experiment.syllabus.hours?size>1]
        ([#list experiment.syllabus.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="6%" property="syllabus.rank.name" title="必修选修"/]
    [@b.col width="7%" property="syllabus.nature.name" title="课程性质"/]
    [@b.col property="name" title="实验项目"/]
    [@b.col width="8%" property="experimentType.name" title="实验类型"/]
    [@b.col width="8%" property="online" title="线上教学"]
      ${experiment.online?string("是","否")}
    [/@]
  [/@]
[/@]
[@b.foot/]
