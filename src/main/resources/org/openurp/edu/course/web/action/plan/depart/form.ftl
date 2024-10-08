[#ftl]
[@b.head/]
[@b.toolbar title="授课计划修改"]
  bar.addBack();
[/@]
[#assign course=clazzPlan.clazz.course/]
  [@b.form theme="list" action=b.rest.save(clazzPlan) name="clazzPlanForm"]
    [@b.field label="课程"]${course.code} ${course.name} ${course.defaultCredits!}学分[/@]
    [@b.select name="clazzPlan.office.id" label="教研室" items=offices value=clazzPlan.office! option="id,name" empty="..." /]
    [@b.formfoot]
      [@b.submit value="保存" /]
    [/@]
  [/@]
[@b.foot/]
