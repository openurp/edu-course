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
    [@b.col width="10%" property="code" title="代码"]${apply.code!"暂无"}[/@]
    [@b.col property="name" title="名称"][@b.a href="!info?id=${apply.id}"]${apply.name}[/@][/@]
    [@b.col width="5%" property="defaultCredits" title="学分"/]
    [@b.col width="5%" property="creditHours" title="学时"]
      ${apply.creditHours}
      [#if apply.hours?size>1]
        ([#list apply.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])
      [/#if]
    [/@]
    [@b.col width="5%" property="weekHours" title="周课时"/]
    [@b.col width="15%" property="department.name" title="开课院系"]
      ${apply.department.shortName!apply.department.name}
    [/@]
    [@b.col width="7%" property="rank.name" title="课程属性"/]
    [@b.col width="15%" property="category.name" title="课程分类"/]
    [@b.col width="7%" property="examMode.name" title="考核方式"/]
    [@b.col width="7%" property="applicant.name" title="申请人"/]
    [@b.col width="7%" property="status" title="状态"/]
  [/@]
  [/@]
[@b.foot/]