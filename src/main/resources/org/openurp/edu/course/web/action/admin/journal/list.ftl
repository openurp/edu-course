[#ftl]
[@b.head/]
[@b.grid items=journals var="journal"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("导入",action.method('importForm'));
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,course.name:课程名称,department.name:开课院系,"+
                "course.defaultCredits:学分,creditHours:学时,[#list teachingNatures as n]hour.${n.id}:${n.name},[/#list]"+
                "examMode.name:考核方式,tags(name):标签",null,'fileName=课程标签信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"]${journal.course.name}[/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${journal.department.shortName!journal.department.name}
    [/@]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="creditHours" title="学时"]
      ${journal.creditHours}
      [#if journal.hours?size>1]
        ([#list journal.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="8%" property="examMode.name" title="考核方式"/]
    [@b.col title="课程标签"]
      <div class="text-ellipsis">[#list journal.course.tags as t]${t.name}[#sep]&nbsp;[/#list]</div>
    [/@]
  [/@]
  [/@]
[@b.foot/]
