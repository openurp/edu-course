[#ftl]
[@b.head/]
[@b.grid items=courseTasks var="courseTask"]
  [@b.gridbar]
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("批量修改",action.multi("batchEdit"));
    bar.addItem("自动指定负责人",action.multi('autoAssign'));
    bar.addItem("自动建组",action.method("autoCreate","是否根据课程名称自动创建课程组？"));
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"][@b.a href="!info?id=${courseTask.id}"]${courseTask.course.name}[/@][/@]
    [@b.col width="8%" property="department.name" title="开课院系"]
      ${courseTask.department.shortName!courseTask.department.name}
    [/@]
    [@b.col width="18%" property="courseType.name" title="课程类型"/]
    [@b.col width="10%" property="director.name" title="负责人"/]
    [@b.col title="任课教师" width="25%"]
      <div class="text-ellipsis">[#list courseTask.teachers as t]${t.name}[#sep]&nbsp;[/#list]</div>
    [/@]
  [/@]
  [/@]
[@b.foot/]
