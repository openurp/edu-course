  [@b.head/]
[@b.toolbar title="编写授课教案"]
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
        <td style="text-align:right;">任课教师：</td><td style="border-bottom: solid 1px black;">[#list clazz.teachers as t]${(t.name)!}[#sep],[/#list]</td>
        <td style="text-align:right;">教  学  班：</td>
        <td style="border-bottom: solid 1px black;display:flex;"><div>(${clazz.crn})</div><div class="text-ellipsis" style="max-width:350px;">${clazz.clazzName}</div></td>
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

  [@b.form action="!save" name="planForm" onsubmit="checkLessons"]
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
        <td>本课程教学内容（实践项目）</td>
        <td>上课形式</td>
        <td>作业布置</td>
      </tr>
      [#list plan.lessons?sort_by('idx') as lesson]
      [#assign totalLessonHours=0/]
      <tr>
        <td>${lesson.idx}</td>
        <td>
          <textarea type="text" name="lesson${lesson_index+1}.contents" style="width:100%" placeholder="第${lesson.idx}次课，教学内容" rows="2">${lesson.contents!}</textarea>
        </td>
        <td>
          <input type="text" name="lesson${lesson_index+1}.forms" style="width:100%" value="${lesson.forms!}" placeholder="上课形式"/>
        </td>
        <td><input type="text" name="lesson${lesson_index+1}.homework" style="width:100%" value="${lesson.homework!}" placeholder="作业布置"/></td>
      </tr>
      [/#list]
      <tr>
        <td colspan="6" style="text-align:left;">注：1.如每周2次课，按照1-1和1-2填写，帮助学生了解教学进度，进行课前预习。2.本学期课程的授课计划中未扣除国定假日，如遇节假日，教学安排适当调整，并确保课程教学大纲完整执行。</td>
      </tr>
    </table>
  </div>

  <div style="text-align:center;margin:10px 0px">
    <input type="hidden" name="clazz.id" value="${clazz.id}"/>
    [@b.submit value="保存" class="btn btn-sm btn-outline-primary"/]
    [#if plan.reviewer??]
    [@b.submit value="提交教研室主任${plan.reviewer.name}审批" id="submit_btn" class="btn btn-sm btn-outline-success" action="!save?submit=1" /]
    [#else]
    <span id="submit_btn">找不到教研室主任，无法提交审核</span>
    [/#if]
  </div>
  [/@]
  <script>
    function checkLessons(form){
      //check lesson
      var missingContents = [];
      var missingLearningHours = [];
      var fillinLearningHours=0;
      if(missingContents.length>0){
        alert("第"+missingContents.join(",")+"次课程，缺少内容或上课形式，请填写");
        return false;
      }
      if(missingLearningHours.length>0){
        alert("第"+missingLearningHours.join(",")+"次课程，缺少自主学习学时，请填写");
        return false;
      }
      return true;
    }
  </script>
</div>
[@b.foot/]
