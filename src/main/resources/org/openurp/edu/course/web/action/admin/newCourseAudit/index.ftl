[#ftl]
[@b.head/]
[@b.toolbar title="新开课程审批"]
[/@]
<div class="search-container">
    <div class="search-panel">
      [@b.form name="applySearchForm" action="!search" target="applylist" title="ui.searchForm" theme="search"]
        [@b.textfield name="apply.code" label="代码" maxlength="5000"/]
        [@b.textfields names="apply.name;名称"/]
        [@b.select name="apply.department.id" label="所属院系" items=departments option="id,name" empty="..." /]
        [@b.select items=ranks name="apply.rank.id" label="课程属性" empty="..." /]
        [@b.select items=categories name="apply.category.id" label="课程分类" empty="..." /]
        <input type="hidden" name="orderBy" value="apply.code"/>
      [/@]
    </div>
    <div class="search-list">[@b.div id="applylist" href="!search?orderBy=apply.code asc&active=1"/]
  </div>
</div>
[@b.foot/]
