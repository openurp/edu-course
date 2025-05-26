[#ftl]
[@b.head/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseTaskSearchForm" action="!search" target="courseTasklist" title="ui.searchForm" theme="search"]
      [@base.semester name="courseTask.semester.id" value=semester label="学年学期"/]
      [@b.textfield name="courseTask.course.code" label="代码"/]
      [@b.textfield name="courseTask.course.name" label="名称"/]
      [@b.select style="width:100px" name="courseTask.department.id" label="开课院系" items=departments option="id,name" empty="..." /]
      [@b.textfield name="teacherName" label="授课教师"/]
      [@b.textfield name="courseTask.director.name" label="负责人"/]
      [@b.select name="courseTask.syllabusRequired" label="大纲要求"]
        <option value="">...</option>
        <option value="1">需要上传大纲</option>
        <option value="0">无需上传大纲</option>
      [/@]
      <input type="hidden" name="orderBy" value="courseTask.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseTasklist" href="!search?courseTask.semester.id=${semester.id}&orderBy=courseTask.course.code asc"/]
  </div>
</div>
[@b.foot/]
