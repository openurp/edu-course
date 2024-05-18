[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  0/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!save" onsubmit="checkInfo" name="syllabusForm"]
    [@b.field label="课程"]${course.code} ${course.name}[/@]
    [@b.field  label="学分学时"]${course.defaultCredits!}学分 ${course.creditHours!}学时 每周${course.weekHours}课时[/@]
    [@b.radios label="语言" required="true" name="syllabus.locale"  style="width:200px;" items=locales value=(syllabus.locale)!/]
    [@base.semester label="生效起始学期" name="syllabus.semester.id" required="true" value=syllabus.semester!/]
    [@b.select name="syllabus.department.id" label="开课院系" value=syllabus.department! required="true"
               style="width:200px;" items=departments option="id,name" empty="..."/]
    [@b.radios name="syllabus.stage.id" label="学期阶段" value=syllabus.stage! required="true" items=calendarStages /]
    [@b.radios name="syllabus.module.id" label="课程模块" value=syllabus.module! items=courseModules empty="..." required="true"/]
    [@b.radios label="必修选修" name="syllabus.rank.id" value=syllabus.rank! items=courseRanks required="true"/]
    [@b.radios name="syllabus.nature.id" label="课程性质" value=syllabus.nature! items=courseNatures empty="..." required="true"/]
    [@b.select name="major.id" label="面向专业" values=syllabus.majors  multiple="true" items=majors required="false" comment="专业课需要该项"/]
    [@b.textfield name="syllabus.methods" label="教学方式" value=syllabus.methods! required="true" style="width:300px" comment="多个方式请用、或者逗号隔开"/]
    [@b.radios name="syllabus.examMode.id" label="考核方式" value=syllabus.examMode! items=examModes /]
    [@b.radios name="syllabus.gradingMode.id" label="成绩记录方式" items=gradingModes value=syllabus.gradingMode!/]
    [#if teachingNatures?size>0]
    [@b.field label="总课时分布"]
       [#assign hours={}/]
       [#list syllabus.hours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       ${course.creditHours!}学时(
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p" style="font-weight:normal;">${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}" onchange="checkCreditHours()">
        [#if ht.category.title=="实践"]
        ，总实践周<input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">
        [/#if]
        [#sep],
       [/#list]
       )
       <span style="color:red" id="credit_hour_tips" style="display:none"></span>
    [/@]
    [/#if]
    [#if syllabus.course.defaultCredits > 1.9]
    [@b.textfield name="syllabus.examCreditHours" label="考核课时" value=syllabus.examCreditHours! style="width:50px" onchange="checkExamHours()"]
       学时([#assign hours={}/]
       [#list syllabus.examHours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="examHour${ht.id}_p" style="font-weight:normal;">${ht.name}</label>
        <input name="examHour${ht.id}" style="width:30px" id="examHour{ht.id}_p" value="${(hours[ht.id?string].creditHours)!}" onchange="checkExamHours()">
        [#sep],
       [/#list])
       <span  style="color:red" id="exam_hour_tips" style="display:none"></span>
    [/@]
    [/#if]
    [@b.number name="syllabus.learningHours" label="自主学习课时" value=syllabus.learningHours!/]
    [@b.textarea name="syllabus.prerequisites" label="先修课程" value=syllabus.prerequisites! rows="2" cols="80"/]
    [@b.textarea name="syllabus.corequisites" label="并修课程" value=syllabus.corequisites!  rows="2" cols="80"/]
    [@b.textarea name="syllabus.subsequents" label="后续课程" value=syllabus.subsequents!  rows="2" cols="80"/]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      [#if syllabus.id??]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [/#if]
      <input type="hidden" name="step" value="objectives"/>
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
<script>
  function checkInfo(form){
    if(!checkCreditHours() || !checkExamHours()){
      return false;
    }
    return true;
  }
  function checkCreditHours(){
    var form = document.syllabusForm;
    var h="";
    var total=0;
    [#list teachingNatures as ht]
    h = form['creditHour${ht.id}'].value
    if(h){
      total += Number.parseInt(h);
    }
    [/#list]
    if(total!=${syllabus.course.creditHours}){
      $("#credit_hour_tips").html("课时小计"+total+"不等于${syllabus.course.creditHours}");
      $("#credit_hour_tips").show();
      return false;
    }
    $("#credit_hour_tips").html("");
    $("#credit_hour_tips").hide();
    return true;
  }
  [#if syllabus.course.defaultCredits > 1.9]
  function checkExamHours(){
    var form = document.syllabusForm;
    var h="";
    var total=0;
    [#list teachingNatures as ht]
    h = form['examHour${ht.id}'].value
    if(h){
      total += Number.parseInt(h);
    }
    [/#list]
    if(total.toString() != form['syllabus.examCreditHours'].value){
      $("#exam_hour_tips").html("课时小计"+total+"不等于"+form['syllabus.examCreditHours'].value);
      $("#exam_hour_tips").show();
      return false;
    }
    $("#exam_hour_tips").html("");
    $("#exam_hour_tips").hide();
    return true;
  }
  [#else]
  function checkExamHours(){
    return true;
  }
  [/#if]

</script>
[@b.foot/]
