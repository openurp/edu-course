[#ftl]
[@b.head/]
[@b.toolbar title="学院课程资料维护"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseSearchForm" action="!search" target="courselist" title="ui.searchForm" theme="search"]
      [@base.semester name="task.semester.id" label="开课学期" value=semester required="true" /]
      [@b.textfields names="task.course.code;代码"/]
      [@b.textfields names="task.course.name;名称"/]
      [@b.select style="width:100px" name="task.course.courseType.id" label="课程类别" items=courseTypes option="id,name" empty="..." /]
      [@b.select style="width:100px" name="task.course.nature.id" label="课程性质" items=courseNatures option="id,name" empty="..." /]
      [#if departments?size > 1]
      [@b.select style="width:100px" name="task.department.id" label="所属院系" items=departments option="id,name" empty="..." /]
      [/#if]
      [@b.select style="width:100px" name="hasProfile" label="课程简介" items={"1":"有", "0":"无"} empty="..." /]
      [@b.select style="width:100px" name="hasSyllabus" label="教学大纲" items={"1":"有", "0":"无"} empty="..." /]
      <input type="hidden" name="orderBy" value="task.course.code"/>
    [/@]
  </div>
  <div class="search-list">[@b.div id="courselist" href="!search?task.semester.id=${semester.id}&orderBy=task.course.code asc" /]</div>
</div>
[@b.foot/]
