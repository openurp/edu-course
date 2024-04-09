[#ftl]
[@b.head/]
[#include "../director_nav.ftl"/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="directorSearchForm" action="!search" target="directorlist" title="ui.searchForm" theme="search"]
      [@b.textfield name="director.course.code" label="代码"/]
      [@b.textfield name="director.course.name" label="名称"/]
      [@b.select style="width:100px" name="director.course.department.id" label="所属院系" items=departments option="id,name" empty="..." /]
      [@b.textfield name="director.director.name" label="负责人"/]
      [@b.select name="assigned" label="是否分配"]
        <option value="">...</option>
        <option value="1">是</option>
        <option value="0">否</option>
      [/@]
      <input type="hidden" name="orderBy" value="director.course.code"/>
    [/@]
  </div>
  <div class="search-list">
    [@b.div id="directorlist" href="!search?orderBy=director.course.code asc"/]
  </div>
</div>
[@b.foot/]
