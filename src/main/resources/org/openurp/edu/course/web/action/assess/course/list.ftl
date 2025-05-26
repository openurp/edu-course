[#ftl]
[@b.head/]
[@b.grid items=courseTasks var="courseTask"]
  [@b.gridbar]
    bar.addItem("达成度分析",action.single("assess"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"][@b.a href="!assess?courseTask.id=${courseTask.id}" target="_blank"]${courseTask.course.name}[/@][/@]
    [@b.col width="7%" property="department.name" title="开课院系"]
      ${courseTask.department.shortName!courseTask.department.name}
    [/@]
    [@b.col width="15%" property="courseType.name" title="课程类型"]
      <div class="text-ellipsis">${courseTask.courseType.name}</div>
    [/@]
    [@b.col width="5%" property="course.defaultCredits" title="学分"/]
    [@b.col width="5%" property="course.creditHours" title="学时"/]
    [@b.col width="10%" property="office.name" title="专业、教研室"]
      <span title="${(courseTask.office.director.name)!}">${(courseTask.office.name)!}</span>
    [/@]
    [@b.col width="8%" property="director.name" title="负责人"/]
    [@b.col title="任课教师" width="13%"]
      <div class="text-ellipsis" title="${courseTask.teachers?size}位老师">[#list courseTask.teachers as t]${t.name}[#sep]&nbsp;[/#list]</div>
    [/@]
  [/@]
  [/@]
[@b.foot/]
