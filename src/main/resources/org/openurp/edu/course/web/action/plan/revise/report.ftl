[@b.head/]
[@b.toolbar title="打印授课计划"]
  bar.addClose();
[/@]
<style>
  .form-table td{border: solid 1px black;padding:5px;}
  .header {
    width:100%;
    border-bottom: 1px solid;
    color:rgb(192,0,0);
    font-family: 楷体;
  }
</style>
<div class="container" style="font-family: 宋体;font-size: 12pt;">
  <table class="header">
    <tr><td><img src="${b.static_url('local','/images/logo.png')}" width="50px"/></td>
    <td style="text-align:right;vertical-align: bottom;">${syllabus.course.project.school.name}·<span style="color:blue;">课程授课计划</span></td>
    </tr>
  </table>
  <div style="width:100%;text-align:center;">
    <p style="font-weight:bold;font-family: 宋体;font-size: 16pt;">《${clazz.course.code} ${clazz.course.name}》</p>
    <p style="font-weight:bold;font-family: 楷体;font-size: 16pt;margin:0px;">【英文名称 ${clazz.course.enName!'--暂无--'}】</p>
  </div>
  <div>
    <table  style="width:100%;">
      <tr>
        <td style="width:15%;text-align:right;">开课学期：</td>
        <td style="width:35%;border-bottom: solid 1px black;">${clazz.semester.schoolYear}学年 ${clazz.semester.name}学期</td>
        <td style="width:15%;text-align:right;">开课学院：</td>
        <td style="width:35%;border-bottom: solid 1px black;">${clazz.teachDepart.name}</td>
      </tr>
      <tr>
        <td style="text-align:right;">任课教师：</td><td style="border-bottom: solid 1px black;">[#list clazz.teachers as t]${t.name}[#sep],[/#list]</td>
        <td style="text-align:right;">教  学  班：</td><td style="border-bottom: solid 1px black;">${clazz.clazzName}</td>
      </tr>
      <tr>
        <td style="text-align:right;">授课时间：</td><td style="border-bottom: solid 1px black;">${schedule_time}</td>
        <td style="text-align:right;">授课地点：</td><td style="border-bottom: solid 1px black;">${schedule_space}</td>
      </tr>
    </table>
  </div>

  <div style="margin-top:30px;">
    <p style="width:100%;text-align:center;font-weight:bold;font-family: 宋体;font-size: 14pt;">（一）课程基本情况</p>
  </div>

  <div>
    <table  style="width:100%;border: solid 1px black;text-align:center;" class="form-table">
      <tr>
        <td rowspan="2" style="width:15%;">课程代码和名称</td>
        <td>中文</td>
        <td colspan="3" style="text-align:left;">${clazz.course.code} ${clazz.course.name}</td>
      </tr>
      <tr>
        <td>英文</td>
        <td colspan="3" style="text-align:left;">${clazz.course.enName!'----'}</td>
      </tr>
      <tr>
        <td rowspan="3">课程学分</td>
        <td rowspan="3">${clazz.course.defaultCredits}</td>
        <td rowspan="3">课程学时或实践周</td>
        <td rowspan="2">①总学时：<br>（其中，理论与实践学时）</td>
        <td>${syllabus.creditHours}学时</td>
      </tr>
      <tr>
        <td>其中：[#list syllabus.hours?sort_by(['nature','code']) as h]${h.nature.name}${h.creditHours}[#sep]，[/#list]</td>
      </tr>
      <tr>
        <td>②总实践周：</td>
        <td>[#if syllabus.weeks?? && syllabus.weeks>0]${syllabus.weeks}周[/#if]</td>
      </tr>
      <tr>
        <td>课程性质</td>
        <td colspan="4">[#if syllabus??]${syllabus.stage.name}-${syllabus.module.name}-${syllabus.rank.name}-${syllabus.nature.name}-${syllabus.examMode.name}[/#if]</td>
      </tr>
      <tr>
        <td>教学方法</td>
        <td colspan="4">${syllabus.methods!}</td>
      </tr>
      <tr>
        <td>选用教材</td>
        <td colspan="2">
          [#if syllabus??]
            [#if syllabus.textbooks?size>0]
              [#list syllabus.textbooks as textbook]
                ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${(textbook.edition)!}
              [/#list]
            [#else]
              使用其他教学资料
            [/#if]
          [/#if]
        </td>
        <td colspan="2"></td>
      </tr>
      <tr>
        <td colspan="5" style="padding: 0px;">
          <table style="width:100%;border: hidden;" >
            <tr>
              <td rowspan="2" style="width:15%;">课程教学活动安排</td>
              <td colspan="${plan.hours?size}">课堂学时</td>
              <td rowspan="2">考试周考核或自主考核*</td>
              <td rowspan="2">合计</td>
              <td rowspan="2">自主学习</td>
            </tr>
            <tr>
              [#list plan.hours as h]
              <td>${h.name}</td>
              [/#list]
            </tr>
            <tr>
              <td>本学期教学学时</td>
              [#list plan.hours as h]
              <td>${h.creditHours}</td>
              [/#list]
              <td>[#if syllabus.examCreditHours>0]${syllabus.examCreditHours}[/#if]</td>
              <td>${syllabus.creditHours}</td>
              <td>[#if syllabus.learningHours>0]${syllabus.learningHours}[/#if]</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td colspan="5" style="text-align:left;">
注：①该计划一式两份，经学院审批后，任课教师、学院各一份，并上传至网络教学平台的课程空间予以公布。②应选马工程教材的课程必须选马工程教材，并按教材组织教学。③教材选用必须符合学校教材选用管理的有关规定。④考试周考核或自主考核为考试周统一组织考试，或者根据教学安排需由教师自行组织的期末考核，一般为一个教学周与学分数相当的学时。
        </td>
      </tr>
    </table>
  </div>

  <div style="margin-top:30px;">
    <p style="width:100%;text-align:center;font-weight:bold;font-family: 宋体;font-size: 14pt;">（二）课程授课安排</p>
  </div>

  <div>
    <table  style="width:100%;border: solid 1px black;text-align:center;" class="form-table">
      <colgroup>
        <col width="5%"/>
        <col width="8%"/>
        <col width="5%"/>
        <col width="50%"/>
        <col width="15%"/>
        <col width="17%"/>
      </colgroup>
      <tr>
        <td colspan="3" style="width:30%;">本课程教学周为：</td>
        <td colspan="3" style="width:70%;">${clazz.schedule.firstWeek}-${clazz.schedule.lastWeek}周</td>
      </tr>
      <tr>
        <td>教学周次</td>
        <td>授课日期</td>
        <td>教学学时</td>
        <td>本课程教学内容（实践项目）</td>
        <td>上课形式</td>
        <td>作业布置</td>
      </tr>
      [#list plan.lessons?sort_by('idx') as lesson]
      <tr>
        <td [#if lesson.learning??]rowspan="2"[/#if]>${lesson.idx}</td>
        <td [#if lesson.learning??]rowspan="2"[/#if]>${(dates[lesson_index])!}</td>
        <td>${syllabus.weekHours}</td>
        <td style="text-align:left;">${lesson.contents!}</td>
        <td>${lesson.forms!}</td>
        <td [#if lesson.learning??]rowspan="2"[/#if]>${lesson.homework!}</td>
      </tr>
      [#if lesson.learning??]
      <tr>
        <td>${lesson.learningHours}</td>
        <td style="text-align:left;">${lesson.learning}</td>
        <td>线上自主学习</td>
      </tr>
      [/#if]
      [/#list]

      [#assign teachingHours=0/]
      [#list plan.hours as h]
        [#assign teachingHours=teachingHours+h.creditHours/]
      [/#list]
      <tr>
        <td colspan="2" style="text-align:left;">课堂教学合计</td>
        <td>${teachingHours}</td> <td colspan="3">&nbsp;</td>
      </tr>
      [#if teachingHours < syllabus.creditHours && syllabus.examCreditHours>0]
      <tr>
        <td colspan="2" style="text-align:left;">期末考核</td>
        <td>${syllabus.examCreditHours}</td>
        <td colspan="3">期末考核</td>
      </tr>
      [/#if]
      [#if syllabus.learningHours>0]
      <tr>
        <td colspan="2" style="text-align:left;">自主学习学时</td>
        <td>${syllabus.learningHours}</td>
        <td colspan="3">&nbsp;</td>
      </tr>
      [/#if]
      <tr>
        <td colspan="2" style="text-align:left;">合计</td>
        <td>${teachingHours + syllabus.examCreditHours+syllabus.learningHours}</td><td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="6" style="text-align:left;">注：1.如每周2次课，按照1-1和1-2填写，帮助学生了解教学进度，进行课前预习。2.本学期课程的授课计划中未扣除国定假日，如遇节假日，教学安排适当调整，并确保课程教学大纲完整执行。</td>
      </tr>
    </table>
  </div>

</div>
[@b.foot/]
