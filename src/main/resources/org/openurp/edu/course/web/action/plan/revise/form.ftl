  [@b.head/]
[@b.toolbar title="编写授课计划"]
  bar.addClose();
[/@]
<style>
  .form-table td{border: solid 1px black;padding:5px;}
</style>
<div class="container" style="font-family: 宋体;font-size: 12pt;">
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

  [@b.form action="!save" name="planForm"]
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
        <td rowspan="2">课程学分</td>
        <td rowspan="2">${clazz.course.defaultCredits}</td>
        <td rowspan="2">课程学时或实践周</td>
        <td>①总学时：<br>（其中，理论与实践学时）</td>
        <td>${clazz.course.creditHours}学时</td>
      </tr>
      <tr>
        <td>②总实践周：</td>
        <td>[#if clazz.course.weeks>0]${clazz.course.weeks}[/#if]</td>
      </tr>
      <tr>
        <td>课程性质</td>
        <td colspan="4">[#if syllabus??]${syllabus.stage.name}-${syllabus.module.name}-${syllabus.rank.name}-${syllabus.nature.name}-${syllabus.examMode.name}[/#if]</td>
      </tr>
      <tr>
        <td>教学方式</td>
        <td colspan="4">${syllabus.methods}</td>
      </tr>
      <tr>
        <td>选用教材</td>
        <td colspan="2">
          [#if syllabus??]
            [#if syllabus.textbooks?size>0]
              [#list syllabus.textbooks as textbook]
                ${textbook.isbn} ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${(textbook.edition)!}
              [/#list]
            [#else]
              自编讲义
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
              <td colspan="${sectionNames?size}">课堂学时</td>
              <td rowspan="2">考试周考核或自主考核*</td>
              <td rowspan="2">合计</td>
              <td rowspan="2">自主学习</td>
            </tr>
            <tr>
              [#list sectionNames as sectionName]
              <td><input name="section${sectionName_index+1}.name" value="${sectionName}" style="width:100%" placeholder="环节名称"/></td>
              [/#list]
            </tr>
            <tr>
              <td>本学期教学学时</td>
              [#list sectionNames as sectionName]
              <td><input name="section${sectionName_index+1}.creditHours" value="${hours.get(sectionName)!}" style="width:100%" placeholder="学时"/></td>
              [/#list]
              <td>[#if syllabus.examCreditHours>0]${syllabus.examCreditHours}[/#if]</td>
              <td>${clazz.course.creditHours}</td>
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
        <col width="10%"/>
        <col width="22%"/>
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
        <td>${lesson.idx}</td>
        <td>${(dates[lesson_index])!}</td>
        <td>${clazz.course.weekHours}</td>
        <td>
          <input type="text" name="lesson${lesson_index+1}.contents" value="${lesson.contents!}" style="width:100%" placeholder="第${lesson.idx}次课，教学内容"/>
          [#if syllabus.learningHours>0]
          <div style="display:flex">
            <input type="text" name="lesson${lesson_index+1}.learning" value="${lesson.learning!}" style="width:80%" placeholder="第${lesson.idx}次课，自主学习内容"/>
            <input type="text" name="lesson${lesson_index+1}.learningHours" value="[#if lesson.learningHours>0]${lesson.learningHours}[/#if]" style="width:20%" placeholder="自主学习课时"/>
          </div>
          [/#if]
        </td>
        <td>
          <input type="text" name="lesson${lesson_index+1}.forms" style="width:100%" value="${lesson.forms!}"/>
        </td>
        <td><input type="text" name="lesson${lesson_index+1}.homework" style="width:100%" value="${lesson.homework!}"/></td>
      </tr>
      [/#list]
      <tr>
        <td colspan="2" style="text-align:left;">2学分及以上课程考核的周学时</td>
        <td></td>
        <td colspan="3">按照学校的统一安排，组织期末考试</td>
      </tr>
      <tr>
        <td colspan="2" style="text-align:left;">课堂教学合计</td>
        <td></td> <td></td> <td></td> <td></td>
      </tr>
      <tr>
        <td colspan="2" style="text-align:left;">合计<br>（含自主学习）</td>
        <td></td> <td></td> <td></td> <td></td>
      </tr>
      <tr>
        <td colspan="6" style="text-align:left;">注：1.如每周2次课，按照1-1和1-2填写，帮助学生了解教学进度，进行课前预习。2.本学期课程的授课计划中未扣除国定假日，如遇节假日，教学安排适当调整，并确保课程教学大纲完整执行。</td>
      </tr>
    </table>
  </div>

  <div style="text-align:center;">
    <input type="hidden" name="clazz.id" value="${clazz.id}"/>

    [@b.submit value="提交"/]
  </div>
  [/@]
</div>
[@b.foot/]
