[#ftl]
[@b.head/]
[@b.grid items=reviseSettings var="reviseSetting"]
  [@b.gridbar]
    bar.addItem("${b.text("action.new")}",action.add());
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col property="semester.code" title="学年学期"]${reviseSetting.semester.schoolYear}学年${reviseSetting.semester.name}学期[/@]
    [@b.col width="30%" property="beginOn" title="生效时间"]${reviseSetting.beginAt!}[/@]
    [@b.col width="30%" property="endOn" title="失效时间"]${reviseSetting.endAt!}[/@]
  [/@]
[/@]
[@b.foot/]
