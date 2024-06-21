[#ftl]
[@b.head/]
[#include "../director_nav.ftl"/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseTaskSearchForm" action="!search" target="courseTasklist" title="ui.searchForm" theme="search"]
      [@base.semester name="courseTask.semester.id" value=semester label="学年学期"/]
      [@b.textfield name="courseTask.course.code" label="代码"/]
      [@b.textfield name="courseTask.course.name" label="名称"/]
      [@b.select style="width:100px" name="courseTask.department.id" label="开课院系" items=departments option="id,name" empty="..." /]
      [@b.select name="courseTask.office.id" label="教研室"  items=offices/]
      [@b.select name="teachers" label="多人授课"]
        <option value="">...</option>
        <option value="2">多人授课</option>
        <option value="1">单人授课</option>
        <option value="0">缺少老师</option>
      [/@]
      [@b.textfield name="teacherName" label="授课教师"/]
      [@b.textfield name="courseTask.director.name" label="负责人"/]
      [@b.select name="assigned" label="是否分配"]
        <option value="">...</option>
        <option value="1">是</option>
        <option value="0">否</option>
      [/@]
      [@b.select name="courseTask.syllabusRequired" label="大纲要求"]
        <option value="">...</option>
        <option value="1">需要上传大纲</option>
        <option value="0">无需上传大纲</option>
      [/@]
      [@b.select name="syllabus_status" label="教学大纲"]
        <option value="">...</option>
        <option value="1">已提交</option>
        <option value="0">未提交</option>
      [/@]
      [@b.select name="schedule_status" label="排课情况"]
        <option value="">...</option>
        <option value="1">已安排</option>
        <option value="0">未安排</option>
      [/@]
      <input type="hidden" name="orderBy" value="courseTask.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseTasklist" href="!search?courseTask.semester.id=${semester.id}&orderBy=courseTask.course.code asc"/]
  </div>
</div>
[@b.foot/]
