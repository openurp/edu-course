[#ftl]
[@b.head/]
[@b.grid items=directors var="director"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("批量修改",action.multi("batchEdit"));
    bar.addItem("从最近学期中提取",action.multi("autoAssisgn"));
    bar.addItem("导入课程",action.method("autoImport"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"][@b.a href="!info?id=${director.id}"]${director.course.name}[/@][/@]
    [@b.col width="8%" property="course.department.name" title="开课院系"]
      ${director.course.department.shortName!director.course.department.name}
    [/@]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="5%" property="course.creditHours" title="学时"/]
    [@b.col width="18%" property="office.name" title="专业/教研室"/]
    [@b.col width="13%" property="director.name" title="负责人"/]
  [/@]
  [/@]
[@b.foot/]
