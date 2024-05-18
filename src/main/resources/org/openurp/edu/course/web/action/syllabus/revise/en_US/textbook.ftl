[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course Syllabus Edit Form"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 6/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveTextbook"]
    [@b.field label="Course"]${course.code} ${course.enName!course.name}[/@]
    [@b.field  label="Credit and Hours"]${course.defaultCredits!} credits ${course.creditHours!} hours[/@]
    [@b.select name="textbook.id" label="Textbooks" required="false" style="width:500px;" items=textbooks values=syllabus.textbooks multiple="true" option="id,name" empty="..."/]
    [@b.textarea name="syllabus.bibliography" label="Bibliographies" value=syllabus.bibliography! required="false" rows="5" cols="80"/]
    [@b.textarea name="syllabus.materials" label="Teaching resources" value=syllabus.materials! required="false" rows="5" cols="80"/]
    [@b.textfield name="syllabus.website" label="Website" value=syllabus.website! required="false" maxlength="300" style="width:500px"/]
    [@b.field label="Reviewer"][#if director??]${director.code} ${director.name}[#else]无相应课程负责人，可以暂时保存，无法提交审核。[/#if][/@]
    [@b.formfoot]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>Previous step</button>
      [@b.submit value="Save" /]
      [#if director??]
      [@b.submit value="Submit" action="!saveTextbook?submit=1"/]
      [/#if]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
