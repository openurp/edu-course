[#ftl]
[@b.head/]
[@b.toolbar title="授课计划学院审核"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="planSearchForm" action="!search" target="planlist" title="ui.searchForm" theme="search"]
      [@base.semester name="clazzPlan.semester.id" value=semester label="学年学期"/]
      [@b.textfield name="clazzPlan.clazz.crn" label="课程序号"/]
      [@b.textfield name="clazzPlan.clazz.course.code" label="课程代码"/]
      [@b.textfield name="clazzPlan.clazz.course.name" label="课程名称"/]
      [@b.select style="width:100px" name="clazzPlan.clazz.teachDepart.id" label="开课院系" items=departs option="id,name" empty="..." /]
      [@b.textfield name="clazzPlan.writer.name" label="编写人"/]
      [@b.select name="clazzPlan.status" label="状态" items=statuses empty="..." /]
      <input type="hidden" name="orderBy" value="clazzPlan.clazz.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="planlist" href="!search?clazzPlan.semester.id=${semester.id}&orderBy=clazzPlan.clazz.course.code asc"/]
  </div>
</div>
[@b.foot/]
