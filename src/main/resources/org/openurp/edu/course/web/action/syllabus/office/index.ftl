[#ftl]
[@b.head/]
[@b.toolbar title="教学大纲教研室审核"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseTaskSearchForm" action="!search" target="courseTasklist" title="ui.searchForm" theme="search"]
      [@base.semester name="semester.id" value=semester label="学年学期"/]
      [@b.textfield name="syllabus.course.code" label="课程代码"/]
      [@b.textfield name="syllabus.course.name" label="课程名称"/]
      [@b.select name="syllabus.office.id" label="教研室" items=offices/]
      <input type="hidden" name="orderBy" value="syllabus.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseTasklist" href="!search?semester.id=${semester.id}&orderBy=syllabus.course.code asc"/]
  </div>
</div>
[@b.foot/]
