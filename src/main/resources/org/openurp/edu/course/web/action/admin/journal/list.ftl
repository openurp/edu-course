[#ftl]
[@b.head/]
[@b.grid items=journals var="journal"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("导入",action.method('importForm'));
    bar.addItem("删除",action.remove());
    [#if departs?size>2]
    bar.addItem("初始化",action.method("init"));
    [/#if]
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,name:课程名称,department.name:开课院系,"+
                "course.defaultCredits:学分,creditHours:学时,[#list teachingNatures as n]hour.${n.id}:${n.name},[/#list]"+
                "examMode.name:考核方式,tags(name):标签",null,'fileName=课程标签信息'));
  [/@]
  [#assign creditHourTitle]学时([#list teachingNatures as n]${n.name}[#sep]+[/#list])[/#assign]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="name" title="名称"]${journal.name}[/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${journal.department.shortName!journal.department.name}
    [/@]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="creditHours" title=creditHourTitle]
      ${journal.creditHours}
      <span [#if !journal.creditHourIdentical]style="color:red"[#else]class="text-muted"[/#if]>([#list teachingNatures as n]${journal.getHour(n)!0}[#sep]+[/#list])</span>
    [/@]
    [@b.col width="8%" property="examMode.name" title="考核方式"/]
    [@b.col title="课程标签"]
      <div class="text-ellipsis">[#list journal.tags as t]${t.name}[#sep]&nbsp;[/#list]</div>
    [/@]
    [@b.col width="10%" property="beginOn" title="有效期"]${journal.beginOn?string("yy-MM")}~${(journal.endOn?string("yy-MM"))!}[/@]
  [/@]
  [/@]
[@b.foot/]
