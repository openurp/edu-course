[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 0/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!save"]
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
    [@b.checkboxes name="teachingMethod.id" label="教学方式" value1=syllabus.methods! required="true" items=teachingMethods /]
    [@b.radios name="syllabus.examMode.id" label="考核方式" value=syllabus.examMode! items=examModes /]
    [@b.radios name="syllabus.gradingMode.id" label="成绩记录方式" items=gradingModes value=syllabus.gradingMode!/]
    [#if teachingNatures?size>0]
    [@b.field label="分类课时"]
       [#assign hours={}/]
       [#list syllabus.hours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">课时
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">实践周
       [/#list]
    [/@]
    [/#if]
    [@b.textarea name="syllabus.prerequisites" label="先修课程" value=syllabus.prerequisites! rows="2" cols="80"/]
    [@b.textarea name="syllabus.corequisites" label="并修课程" values=syllabus.corequisites!  rows="2" cols="80"/]
    [@b.textarea name="syllabus.subsequents" label="后续课程" values=syllabus.subsequents!  rows="2" cols="80"/]
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
