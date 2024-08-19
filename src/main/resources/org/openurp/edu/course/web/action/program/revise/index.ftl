[@b.head/]
<div class="container-fluid">
  [@b.toolbar title="我的授课教案"]
  [/@]
  [@base.semester_bar value=semester! formName='courseTableForm'/]
  <div class="search-container">
    <div class="search-list">
    [@b.grid items=clazzes var="clazz"]
      [@b.row]
        [@b.col width="5%" title="序号"]${clazz_index+1}[/@]
        [@b.col width="8%" title="课程序号"]${(clazz.crn)?if_exists}[/@]
        [@b.col width="10%" title="课程代码"]${(clazz.course.code)?if_exists}[/@]
        [@b.col title="课程名称"]${(clazz.course.name)?if_exists}[/@]
        [@b.col width="15%" title="课程类型"]${(clazz.courseType.name)?if_exists}[/@]
        [@b.col width="5%" title="学分"]${clazz.course.defaultCredits}[/@]
        [@b.col width="5%" title="总学时"]${(clazz.course.creditHours)?if_exists}[/@]
        [@b.col width="5%" title="学生数"]${clazz.enrollment.courseTakers?size}[/@]
        [@b.col width="10%" title="任课教师"][#list clazz.teachers as t]${t.name}[#sep] [/#list][/@]
        [@b.col width="19%" title="操作"]
          [#if plans.get(clazz)??]
            [@b.a href="!edit?clazz.id="+clazz.id target="_blank"]编写[/@]
            [#--[#if programs.get(clazz)??]
              [@b.a href="!report?plan.id="+plans.get(clazz).id target="_blank"]预览[/@]
              [@b.a href="!pdf?plan.id="+plans.get(clazz).id target="_blank"]下载PDF[/@]
            [/#if]
            --]
          [#else]
            授课计划缺失，请先修订授课计划
          [/#if]
        [/@]
      [/@]
    [/@]
    </div>
  </div>
</div>
[@b.foot/]
