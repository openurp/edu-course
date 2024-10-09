[#ftl]
[@b.head/]
[@b.toolbar title="获奖信息"/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="courseAwardSearchForm" action="!search" target="courseAwardlist" title="ui.searchForm" theme="search"]
      [@b.textfield name="courseAward.course.code" label="课程代码"/]
      [@b.textfield name="courseAward.course.name" label="课程名称"/]
      [@b.select style="width:100px" name="courseAward.course.department.id" label="开课院系" items=departments option="id,name" empty="..." /]
      [@b.select name="courseAward.awardType.id" label="获奖类型"  items=awardTypes/]
      [@b.textfield name="courseAward.schoolYear" label="获奖年度"/]
      <input type="hidden" name="orderBy" value="courseAward.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="courseAwardlist" href="!search?orderBy=courseAward.course.code asc"/]
  </div>
</div>
[@b.foot/]
