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
    [@b.field label="课程"]${course.code} ${course.name} ${course.defaultCredits!}学分 ${syllabus.creditHours}学时[/@]
    [@b.radios label="语言" required="true" name="syllabus.docLocale"  style="width:200px;" items=locales value=(syllabus.docLocale)!/]
    [@b.field label="生效学期"]${syllabus.semester.schoolYear}学年${syllabus.semester.name}学期[/@]
    [@b.field label="开课院系"]${departments?first.name}[/@]
    [@b.radios name="syllabus.stage.id" label="学期阶段" value=syllabus.stage! required="true" items=calendarStages /]
    [@b.radios name="syllabus.module.id" label="课程模块" value=syllabus.module! items=courseModules empty="..." required="true"/]
    [@b.radios label="必修选修" name="syllabus.rank.id" value=syllabus.rank! items=courseRanks required="true"/]
    [@b.radios name="syllabus.nature.id" label="课程性质" value=syllabus.nature! items=courseNatures empty="..." required="true"/]
    [@b.select name="major.id" label="面向专业" values=syllabus.majors  multiple="true" items=majors required="false" comment="专业课需要该项"/]
    [@b.textfield name="syllabus.methods" label="教学方法" value=syllabus.methods! required="true" style="width:300px" comment="多个方式请用、或者逗号隔开"/]
    [@b.radios name="syllabus.examMode.id" label="考核方式" value=syllabus.examMode! items=examModes /]
    [@b.radios name="syllabus.gradingMode.id" label="成绩记录方式" items=gradingModes value=syllabus.gradingMode!/]
    [#if teachingNatures?size>0]
    [@b.field label="总学时分布" required="true"]
       [#assign hours={}/]
       [#list syllabus.hours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p" style="font-weight:normal;">${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}" onchange="checkCreditHours()">
        [#sep],
       [/#list]
       <span style="color:red" id="credit_hour_tips" style="display:none"></span>
    [/@]
    [/#if]
    [@b.number name="syllabus.learningHours" label="自主学习学时" value=syllabus.learningHours!/]
    [@b.textarea name="syllabus.prerequisites" label="先修课程" value=syllabus.prerequisites! rows="2" cols="80"/]
    [@b.textarea name="syllabus.corequisites" label="并修课程" value=syllabus.corequisites!  rows="2" cols="80"/]
    [@b.textarea name="syllabus.subsequents" label="后续课程" value=syllabus.subsequents!  rows="2" cols="80"/]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.department.id" value="${departments?first.id}"/>
      <input type="hidden" name="syllabus.semester.id" value="${syllabus.semester.id}"/>
      [#if syllabus.id??]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [/#if]
      <input type="hidden" name="syllabus.creditHours" value="${syllabus.creditHours}"/>
      <input type="hidden" name="step" value="objectives"/>
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
<script>
  function checkInfo(form){
    if(!checkCreditHours()){
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
    var creditHours = form['syllabus.creditHours'].value || "0";
    if(total!= parseInt(creditHours)){
      $("#credit_hour_tips").html("学时小计"+total+"不等于" + creditHours);
      $("#credit_hour_tips").show();
      return false;
    }
    $("#credit_hour_tips").html("");
    $("#credit_hour_tips").hide();
    return true;
  }
  checkInfo();
</script>
[@b.foot/]
