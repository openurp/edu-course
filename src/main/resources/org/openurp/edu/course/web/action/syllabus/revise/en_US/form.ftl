[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course syllabus edit form"]
  bar.addClose();
[/@]
<style>
  fieldset.listset li > label.title{
    min-width: 10rem;
  }
</style>
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 0/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!save"]
    [@b.field label="Course"]${course.code} ${course.name}[/@]
    [@b.field  label="Credit"]${course.defaultCredits!} Credits ${course.creditHours!} Hours ${course.weekHours} per week[/@]
    [@b.radios label="Language" required="true" name="syllabus.locale"  style="width:200px;" items=locales value=(syllabus.locale)!/]
    [@base.semester label="Semester" name="syllabus.semester.id" required="true" value=syllabus.semester!/]
    [@b.select name="syllabus.department.id" label="Department" value=syllabus.department! required="true"
               style="width:200px;" items=departments option="id,name" empty="..."/]
    [@b.radios name="syllabus.stage.id" label="Semester Stage" value=syllabus.stage! required="true" items=calendarStages /]
    [@b.radios name="syllabus.module.id" label="Course Module" value=syllabus.module! items=courseModules empty="..." required="true" valueName="enName2"/]
    [@b.radios label="Compulsory/Selective" name="syllabus.compulsory" value=syllabus.compulsory items="1:Yes,0:No" required="true"/]
    [@b.radios name="syllabus.nature.id" label="Theoretical/Practical" value=syllabus.nature! items=courseNatures empty="..." required="true" valueName="enName2"/]
    [@b.checkboxes name="teachingMethod.id" label="Teaching Manners" value=syllabus.methods! required="true" items=teachingMethods valueName="enName2"/]
    [@b.radios name="syllabus.examMode.id" label="Examination/Test" value=syllabus.examMode! items=examModes valueName="enName2" /]
    [@b.radios name="syllabus.gradingMode.id" label="Grading Mode" items=gradingModes value=syllabus.gradingMode! valueName="enName2"/]
    [#if teachingNatures?size>0]
    [@b.field label="分类课时"]
       [#assign hours={}/]
       [#list syllabus.hours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">课时
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">周
       [/#list]
    [/@]
    [/#if]
    [@b.select name="prerequisites" label="Prerequisite course(s)" items=curriculums values=syllabus.prerequisites multiple="true"/]
    [@b.select name="corequisites" label="Corequisites course(s)" items=curriculums values=syllabus.corequisites multiple="true"/]
    [@b.select name="subsequents" label="Subsequent course(s)" items=curriculums values=syllabus.subsequents multiple="true"/]
    [@b.textarea label="Descriptions" name="syllabus.description" value=syllabus.description! cols="80" rows="6" required="true"
      maxlength="500" comment="Up to 500 characters" placeholder="Description"/]
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
[@b.foot/]
