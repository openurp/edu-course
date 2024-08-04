[#ftl]
[@b.head/]
[@b.grid items=clazzPlans var="clazzPlan"]
  [@b.gridbar]
    bar.addItem("审核通过",action.multi("audit","确认审核通过?","passed=1"));
    bar.addItem("驳回修改",action.multi("audit","确认驳回修改?","passed=0"));
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("未上传明细","notUploaded()");
    bar.addItem("选中下载",action.multi("download","选择数量较多时,下载时间较长，请稍后",null,"_blank"));
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
    function notUploaded(){
      bg.form.submit(document.courseTaskForm);
    }
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="6%" property="clazz.crn" title="课程序号"/]
    [@b.col width="10%" property="clazz.course.code" title="课程代码"/]
    [@b.col property="clazz.course.name" title="课程名称"]
      [@b.a href="!info?id="+clazzPlan.id target="_blank"]${clazzPlan.clazz.course.name}[/@]
    [/@]
    [@b.col width="8%" property="clazz.teachDepart.name" title="开课院系"]
      ${clazzPlan.clazz.teachDepart.shortName!clazzPlan.clazz.teachDepart.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
    [@b.col width="10%" property="office.name" title="教研室"]
      <div class="text-ellipsis" title="负责人:${(clazzPlan.office.director.name)!}">${(clazzPlan.office.name)!}</div>
    [/@]
    [@b.col width="6%" property="clazz.course.defaultCredits" title="学分"/]
    [@b.col width="6%" property="clazz.course.creditHours" title="学时"/]
    [@b.col width="6%" property="lessonHours" title="课堂学时"/]
    [@b.col width="6%" property="examHours" title="考核学时"/]
    [@b.col width="9%" property="status" title="状态"/]
  [/@]
[/@]
[@b.form name="courseTaskForm" action="/admin/task/search"]
  <input type="hidden" name="plan_status" value="0"/>
  <input type="hidden" name="hideMenus" value="1"/>
  <input type="hidden" name="courseTask.semester.id" value="${Parameters['clazzPlan.semester.id']!}"/>
  <input type="hidden" name="courseTask.department.id" value="${Parameters['clazzPlan.clazz.teachDepart.id']!}"/>
[/@]
[@b.foot/]
