[#ftl]
[@b.head/]
[@b.toolbar title="课程信息维护"]
[/@]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="journalSearchForm" action="!search" target="journallist" title="ui.searchForm" theme="search"]
      [@b.select style="width:100px" name="grade.id" label="适用年级" value=grade items=grades required="true" option="id,name" empty="..." /]
      [@b.textfield name="journal.course.code" label="代码"/]
      [@b.textfield name="journal.course.name" label="名称"/]
      [@b.select style="width:100px" name="journal.department.id" label="开课院系" items=departments option="id,name" empty="..." /]
      [@b.textfield name="tagName" label="课程标签"/]
      [@b.select name="creditHourStatus" label="课时分布" items={"1":"正确","0":"存在错误"} /]
      [@b.select name="tagStatus" label="标记情况" items={"1":"有标签","0":"没有标签"} /]
      [@b.select name="planIncluded" label="培养计划" items={"1":"计划内课程","0":"计划外课程"} /]
      <input type="hidden" name="orderBy" value="journal.course.code asc"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="journallist" /]
  </div>
</div>

<script>
  jQuery(document).ready(function(){
    bg.form.submit(document.journalSearchForm);
  });
</script>
[@b.foot/]
