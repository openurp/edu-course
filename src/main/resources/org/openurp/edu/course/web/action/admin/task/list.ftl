[#ftl]
[@b.head/]
[@b.grid items=courseTasks var="courseTask"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("批量修改",action.multi("batchEdit"));
    bar.addItem("自动指定负责人",action.multi('autoAssign'));
    bar.addItem("初始化",action.method("autoCreate"));
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
    bar.addItem("导入",action.method('importForm'));
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,course.name:课程名称,course.defaultCredits:学分,course.creditHours:学时,"+
                "department.name:开课院系,courseType.name:课程类型,office.name:专业教研室,"+
                "direction.name:课程负责人,teachers:任课教师",
                null,'fileName=课程负责人信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"][@b.a href="!info?id=${courseTask.id}"]${courseTask.course.name}[/@][/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${courseTask.department.shortName!courseTask.department.name}
    [/@]
    [@b.col width="15%" property="courseType.name" title="课程类型"/]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="5%" property="course.creditHours" title="学时"/]
    [@b.col width="14%" property="office.name" title="专业、教研室"/]
    [@b.col width="10%" property="director.name" title="负责人"/]
    [@b.col title="任课教师" ]
      <div class="text-ellipsis">[#list courseTask.teachers as t]${t.name}[#sep]&nbsp;[/#list]</div>
    [/@]
  [/@]
  [/@]
[@b.foot/]
