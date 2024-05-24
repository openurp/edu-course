[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  6/]
[#if warningMessages?size>0]
<div class="alert alert-warning">
   [#list warningMessages as msg]${msg}<br>[/#list]
</div>
[/#if]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveTextbook"]
    [@b.field label="课程"]${course.code} ${course.name}[/@]
    [@b.field  label="学分学时"]${course.defaultCredits!}学分 ${course.creditHours!}学时[/@]
    [@b.select name="textbook.id" label="教材" required="false" style="width:600px;" items=textbooks values=syllabus.textbooks multiple="true" option=r"${item.isbn!} ${item.name} ${item.author} ${(item.press.name)!} 版次:${item.edition!}" empty="..."/]
    [@b.textarea name="syllabus.bibliography" label="参考书目" value=syllabus.bibliography! required="false" rows="4" cols="80"/]
    [@b.textarea name="syllabus.materials" label="其他教学资源" value=syllabus.materials! required="false" rows="4" cols="80"/]
    [@b.textfield name="syllabus.website" label="课程网站" value=syllabus.website! required="false" maxlength="300" style="width:500px"/]
    [@b.field label="负责人"][#if director??]${director.code} ${director.name}[#else]无相应课程负责人，可以暂时保存，无法提交审核。[/#if][/@]
    [@b.formfoot]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
      [@b.submit value="保存" /]
      [#if warningMessages?size=0 && director??]
      [@b.submit value="提交教研室审批" action="!saveTextbook?submit=1"/]
      [/#if]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
