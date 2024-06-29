[#ftl]
[@b.head/]
[@b.grid items=applies var="apply"]
  [@b.gridbar]
    bar.addItem("${b.text("action.new")}",action.add());
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="9%" property="code" title="代码"]${apply.code!"暂无"}[/@]
    [@b.col property="name" title="名称"][@b.a href="!info?id=${apply.id}"]${apply.name}[/@][/@]
    [@b.col width="5%" property="defaultCredits" title="学分"/]
    [@b.col width="8%" property="creditHours" title="学时"]
      ${apply.creditHours}
      [#if apply.hours?size>1]
        ([#list apply.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="6%" property="department.name" title="开课院系"]
      ${apply.department.shortName!apply.department.name}
    [/@]
    [@b.col width="9%" property="module.name" title="课程模块"/]
    [@b.col width="5%" property="rank.name" title="课程属性"/]
    [@b.col width="5%" property="nature.name" title="课程性质"/]
    [@b.col width="12%" property="category.name" title="课程分类"]
      <div class="text-ellipsis" title="${apply.category.name}">${apply.category.name}</div>
    [/@]
    [@b.col width="5%" property="examMode.name" title="考核方式"/]
    [@b.col width="7%" property="applicant.name" title="申请人"/]
    [@b.col width="10%" property="status" title="状态"]
      [#if apply.status.id==99]
      <div title="${apply.opinions!}" class="text-ellipsis" style="color:red">${apply.opinions!}</div>
      [#else]
      ${apply.status}
      [/#if]
    [/@]
  [/@]
[/@]
[@b.foot/]
