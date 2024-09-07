[#ftl]
[@b.head/]
[@b.toolbar title="教学大纲学院管理"]
  bar.addItem("上传统计","stat()");
  function stat(){
    bg.form.submit(document.courseTaskSearchForm,"${b.url('!stat')}","main");
  }
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseTaskSearchForm" action="!search" target="courseTaskList" title="ui.searchForm" theme="search"]
      [@base.semester name="semester.id" value=semester label="学年学期"/]
      [@b.textfield name="syllabus.course.code" label="课程代码"/]
      [@b.textfield name="syllabus.course.name" label="课程名称"/]
      [@b.select style="width:100px" name="syllabus.department.id" label="开课院系" items=departs option="id,name" empty="..." /]
      [@b.textfield name="syllabus.office.name" label="教研室"/]
      [@b.textfield name="syllabus.writer.name" label="编写人"/]
      [@b.select  name="syllabus.status" label="状态" items=statuses empty="..." /]
      [@b.select style="width:100px" name="hasTopics" label="教学主题" items={"1":"有", "0":"无"} empty="..." /]
      [@b.select style="width:100px" name="syllabus.complete" label="是否完整" items={"1":"是", "0":"否"} empty="..." /]
      <input type="hidden" name="orderBy" value="syllabus.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseTaskList" href="!search?semester.id=${semester.id}&orderBy=syllabus.course.code asc"/]
  </div>
</div>
[@b.foot/]
