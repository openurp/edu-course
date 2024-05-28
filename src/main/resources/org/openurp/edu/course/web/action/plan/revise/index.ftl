[@b.head/]
<div class="container-fluid">
  [@b.toolbar title="我的授课计划"]
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
        [@b.col width="12%" title="课程类型"]${(clazz.courseType.name)?if_exists}[/@]
        [@b.col width="5%" title="学分"]${clazz.course.defaultCredits}[/@]
        [@b.col width="5%" title="总学时"]${(clazz.course.creditHours)?if_exists}[/@]
        [@b.col width="5%" title="学生数"]${clazz.enrollment.courseTakers?size}[/@]
        [@b.col width="19%" title="操作"]
          [#if syllabusCourses?seq_contains(clazz.course)]
             [#if !plans.get(clazz)?? || editables?seq_contains(plans.get(clazz).status)][@b.a href="!edit?clazz.id="+clazz.id target="_blank"]编写[/@][#else]${(plans.get(clazz).status)!'--'}[/#if]
          [#else]
            课程大纲缺失，请先修订大纲
          [/#if]
          [#if plans.get(clazz)??]
            [@b.a href="!report?plan.id="+plans.get(clazz).id target="_blank"]预览[/@]
          [/#if]
        [/@]
      [/@]
    [/@]
    </div>
  </div>
</div>
[@b.foot/]
