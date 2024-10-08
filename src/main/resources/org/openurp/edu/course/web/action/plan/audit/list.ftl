[#ftl]
[@b.head/]
[@b.grid items=clazzPlans var="clazzPlan"]
  [@b.gridbar]
    bar.addItem("审核通过",action.multi("audit","确认审核通过?","passed=1"));
    bar.addItem("驳回修改",action.multi("audit","确认驳回修改?","passed=0"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="clazz.crn" title="课程序号"/]
    [@b.col width="10%" property="clazz.course.code" title="课程代码"/]
    [@b.col property="clazz.course.name" title="课程名称"]
      [@b.a href="!info?id="+clazzPlan.id target="_blank"]${clazzPlan.clazz.course.name}[/@]
    [/@]
    [@b.col width="8%" property="clazz.teachDepart.name" title="开课院系"]
      ${clazzPlan.clazz.teachDepart.shortName!clazzPlan.clazz.teachDepart.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
    [@b.col width="5%" property="clazz.course.defaultCredits" title="学分"/]
    [@b.col width="10%" property="clazz.course.creditHours" title="学时"/]
    [@b.col width="10%" property="status" title="状态"/]
  [/@]
  [/@]
[@b.foot/]
