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
        <td style="text-align:right;">任课教师：</td><td style="border-bottom: solid 1px black;">[#list clazz.teachers as t]${(t.name)!}[#sep],[/#list]</td>
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
        <td>${syllabus.creditHours}学时</td>
      </tr>
      <tr>
        <td>②总实践周：</td>
        <td>[#if syllabus.weeks>0]${syllabus.weeks}周[/#if]</td>
      </tr>
      <tr>
        <td>课程性质</td>
        <td colspan="4">[#if syllabus??]${syllabus.stage.name}-${syllabus.module.name}-${syllabus.rank.name}-${syllabus.nature.name}-${syllabus.examMode.name}[/#if]</td>
      </tr>
      <tr>
        <td>教学方法</td>
        <td colspan="4">${syllabus.methods}</td>
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
              <td colspan="${sectionNames?size}">课堂学时([#if scheduleHours == syllabus.creditHours]${scheduleHours - syllabus.examCreditHours}[#else]${scheduleHours}[/#if])<span id="schedule_hour_tips"></span></td>
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
              <td><input name="section${sectionName_index+1}.creditHours" value="${hours.get(sectionName)!}" style="width:100%" placeholder="学时" onchange="checkHours(this)"/></td>
              [/#list]
              <td>${syllabus.examCreditHours}</td>
              <td>[#if scheduleHours == syllabus.creditHours]${scheduleHours}[#else]${syllabus.examCreditHours+scheduleHours}[/#if]</td>
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
      [#assign totalLessonHours=0/]
      <tr>
        <td>${lesson.idx}</td>
        <td>${(schedules[lesson_index].date)!} ${(schedules[lesson_index].units)!}</td>
        <td>[#if schedules[lesson_index]??]${schedules[lesson_index].hours} [#assign totalLessonHours=totalLessonHours +schedules[lesson_index].hours/][/#if]</td>
        <td>
          <textarea type="text" name="lesson${lesson_index+1}.contents" style="width:100%" placeholder="第${lesson.idx}次课，教学内容" rows="2">${lesson.contents!}</textarea>
          [#if syllabus.learningHours>0]
          <div style="display:flex">
            <input type="text" name="lesson${lesson_index+1}.learning" value="${lesson.learning!}" style="width:80%" placeholder="第${lesson.idx}次课，自主学习内容"/>
            <input type="text" name="lesson${lesson_index+1}.learningHours" value="[#if lesson.learningHours>0]${lesson.learningHours}[/#if]" style="width:20%" placeholder="自主学习课时"/>
          </div>
          [/#if]
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
    [#if syllabus??]
    <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
    <input type="hidden" name="lessonHours" value="[#if scheduleHours == syllabus.creditHours]${scheduleHours - syllabus.examCreditHours}[#else]${scheduleHours}[/#if]"/>
    [/#if]
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
      for(var i=1;i<=${schedules?size};i++){
        if(!form['lesson'+i+".contents"].value || !form['lesson'+i+".forms"].value){
          missingContents.push(i);
        }
        if(form['lesson'+i+".learning"] && form['lesson'+i+".learning"].value){
          if(!form['lesson'+i+".learningHours"].value){
            missingLearningHours.push(i);
          }else{
            fillinLearningHours += parseFloat( form['lesson'+i+".learningHours"].value)
          }
        }
      }
      if(missingContents.length>0){
        alert("第"+missingContents.join(",")+"次课程，缺少内容或上课形式，请填写");
        return false;
      }
      if(missingLearningHours.length>0){
        alert("第"+missingLearningHours.join(",")+"次课程，缺少自主学习学时，请填写");
        return false;
      }
      if(fillinLearningHours!=${syllabus.learningHours}){
        alert("本次填写自主学习学时为"+fillinLearningHours+"和大纲中的${syllabus.learningHours}不相符,请调整");
        return false;
      }
      //check hours
      var warnings = checkHours();
      if(warnings){
        return !confirm(warnings+"，继续填写?");
      }else{
        return true;
      }
    }

    function checkHours(){
      var hours = 0;
    [#list sectionNames as sectionName]
      hours += parseInt(document.planForm["section${sectionName_index+1}.creditHours"].value||'0');
    [/#list]
      var warnings="";
      var scheduleHours = [#if scheduleHours == syllabus.creditHours]${scheduleHours - syllabus.examCreditHours}[#else]${scheduleHours}[/#if]
      var totalHours = ${syllabus.creditHours};
      if(hours != scheduleHours){
        warnings ="分项累计为"+hours+"学时，不等于课堂学时"+scheduleHours;
      }else if(hours + ${syllabus.examCreditHours} < totalHours){
        warnings="课堂学时+期末考核学时少于"+totalHours+"学时";
      }

      if(warnings){
        document.getElementById("schedule_hour_tips").innerHTML=warnings;
        document.getElementById("schedule_hour_tips").style.color="red";
        jQuery("#submit_btn").attr("disabled",true);
      }else{
        document.getElementById("schedule_hour_tips").innerHTML="";
        document.getElementById("schedule_hour_tips").style.color="green";
        jQuery("#submit_btn").attr("disabled",false);
      }
      return warnings;
    }
    checkHours();
  </script>
</div>
[@b.foot/]
