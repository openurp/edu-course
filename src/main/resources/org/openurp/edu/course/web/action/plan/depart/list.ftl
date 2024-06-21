[#ftl]
[@b.head/]
[@b.grid items=teachingPlans var="teachingPlan"]
  [@b.gridbar]
    //bar.addItem("审核通过",action.multi("audit","确认审核通过?","passed=1"));
    //bar.addItem("驳回修改",action.multi("audit","确认驳回修改?","passed=0"));
    bar.addItem("未上传明细","notUploaded()");
    function notUploaded(){
      bg.form.submit(document.courseTaskForm);
    }
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="clazz.crn" title="课程序号"/]
    [@b.col width="10%" property="clazz.course.code" title="课程代码"/]
    [@b.col property="clazz.course.name" title="课程名称"]
      [@b.a href="!info?id="+teachingPlan.id target="_blank"]${teachingPlan.clazz.course.name}[/@]
    [/@]
    [@b.col width="8%" property="clazz.teachDepart.name" title="开课院系"]
      ${teachingPlan.clazz.teachDepart.shortName!teachingPlan.clazz.teachDepart.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
    [@b.col width="5%" property="clazz.course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="clazz.course.creditHours" title="学时"/]
    [@b.col width="10%" property="status" title="状态"/]
  [/@]
[/@]
[@b.form name="courseTaskForm" action="/admin/task/search"]
  <input type="hidden" name="plan_status" value="0"/>
  <input type="hidden" name="courseTask.semester.id" value="${Parameters['teachingPlan.semester.id']!}"/>
  <input type="hidden" name="courseTask.department.id" value="${Parameters['teachingPlan.clazz.teachDepart.id']!}"/>
[/@]
[@b.foot/]
