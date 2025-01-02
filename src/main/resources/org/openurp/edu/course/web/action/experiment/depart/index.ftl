[#ftl]
[@b.head/]
[@b.toolbar title="学院实验项目查询"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="searchForm" action="!search" target="courseTaskList" title="ui.searchForm" theme="search"]
      [@base.semester name="semester.id" value=semester label="学年学期"/]
      [@b.textfield name="experiment.syllabus.course.code" label="课程代码" maxlength="200000"/]
      [@b.textfield name="experiment.syllabus.course.name" label="课程名称"/]
      [@b.select style="width:100px" name="experiment.syllabus.department.id" label="开课院系" items=departs option="id,name" empty="..." /]
      [@b.textfield name="experiment.syllabus.office.name" label="教研室"/]
      [@b.textfield name="experiment.syllabus.writer.name" label="编写人"/]
      <input type="hidden" name="orderBy" value="experiment.syllabus.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseTaskList" href="!search?semester.id=${semester.id}&orderBy=experiment.syllabus.course.code asc"/]
  </div>
</div>
[@b.foot/]
