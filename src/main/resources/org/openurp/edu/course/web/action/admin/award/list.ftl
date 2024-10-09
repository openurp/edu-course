[#ftl]
[@b.head/]
[@b.grid items=courseAwards var="courseAward"]
  [@b.gridbar]
    bar.addItem("${b.text("action.export")}",
                action.exportData("course.code:课程代码,course.name:课程名称,course.defaultCredits:学分,course.creditHours:学时,"+
                "course.department.name:开课院系,schoolYear:获奖年度,awardType.name:获奖类型",
                null,'fileName=课程获奖信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="course.code" title="代码"/]
    [@b.col property="course.name" title="名称"][@b.a href="!info?id=${courseAward.id}"]${courseAward.course.name}[/@][/@]
    [@b.col width="7%" property="course.department.name" title="开课院系"]
      ${courseAward.course.department.shortName!courseAward.course.department.name}
    [/@]
    [@b.col width="15%" property="awardType.name" title="获奖类型"]
      <div class="text-ellipsis">${courseAward.awardType.name}</div>
    [/@]
    [@b.col width="5%" property="schoolYear" title="学年度"/]
  [/@]
  [/@]
[@b.foot/]
