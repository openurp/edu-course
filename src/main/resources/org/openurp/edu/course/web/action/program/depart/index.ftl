[#ftl]
[@b.head/]
[@b.toolbar title="教案学院管理"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="planSearchForm" action="!search" target="planlist" title="ui.searchForm" theme="search"]
      [@base.semester name="clazzProgram.semester.id" value=semester label="学年学期"/]
      [@b.textfield name="clazzProgram.clazz.crn" label="课程序号"/]
      [@b.textfield name="clazzProgram.clazz.course.code" label="课程代码"/]
      [@b.textfield name="clazzProgram.clazz.course.name" label="课程名称"/]
      [@b.select style="width:100px" name="clazzProgram.clazz.teachDepart.id" label="开课院系" items=departs option="id,name" empty="..." /]
      [@b.textfield name="clazzProgram.writer.name" label="编写人"/]
      [@b.date name="lessonOn" value="" label="开课日期" /]
      [@b.textfield name="unit" value="" label="上课小节" placeholder="数字"/]
      [@b.select style="width:100px" name="checkHour" label="课时核对" items={"1":"偏多", "0":"吻合","-1":"偏少"} empty="..." /]
      <input type="hidden" name="orderBy" value="clazzProgram.clazz.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="planlist" href="!search?clazzProgram.semester.id=${semester.id}&orderBy=clazzProgram.clazz.course.code asc"/]
  </div>
</div>
[@b.foot/]
