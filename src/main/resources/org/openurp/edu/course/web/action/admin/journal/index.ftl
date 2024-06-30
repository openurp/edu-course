[#ftl]
[@b.toolbar title="课程标签"]
[/@]
[@b.head/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="journalSearchForm" action="!search" target="journallist" title="ui.searchForm" theme="search"]
      [@b.select style="width:100px" name="grade.id" label="适用年级" value=grades?first items=grades option="id,name" empty="..." /]
      [@b.textfield name="journal.course.code" label="代码"/]
      [@b.textfield name="journal.course.name" label="名称"/]
      [@b.select style="width:100px" name="journal.department.id" label="开课院系" items=departments option="id,name" empty="..." /]
      [@b.select name="creditHourStatus" label="课时分布"]
        <option value="">...</option>
        <option value="1">正确</option>
        <option value="0">存在错误</option>
      [/@]
      <input type="hidden" name="orderBy" value="journal.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="journallist" href="!search?grade.id=${grades?first.id}&orderBy=journal.course.code asc"/]
  </div>
</div>
[@b.foot/]
