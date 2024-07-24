[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  1/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [#assign placeholders=["思想政治素质目标","诚信品质"]/]
  [@b.form theme="list" action="!saveObjectives"]
    [@b.textarea label="课程介绍" name="syllabus.description" value=syllabus.description! cols="100" rows="5"
      maxlength="3000" comment=tips['syllabus.description']! required="true"/]
    [@b.textarea label="课程的价值引领"  name="values" value="${(syllabus.getText('values').contents)!}" cols="100" rows="4" placeholder="经世济民、诚信服务等职业素养，课程根据思政教育和课程思政的安排，在本课程中融入的课程思政教学内容。"
      maxlength="500" required="true"]
      <div style="display:inline-block;max-width:155px;">${tips['values']!}</div>
    [/@]
    [#list 1..8 as i]
    [#assign required][#if i<4]true[#else]false[/#if][/#assign]
    [@b.textarea label="课程目标CO"+i name="CO"+i value="${(syllabus.getObjective('CO'+i).contents)!}" cols="100" rows="3"  required=required
      maxlength="500" comment="500字以内" placeholder=((placeholders[i-1])!"") /]
    [/#list]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="requirements"/>
      [@b.a href="!edit?syllabus.id=${syllabus.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit action="!saveObjectives?justSave=1"]<i class="fa-solid fa-floppy-disk"></i>保存[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>

[#--
价值目标最少几个？
--]
[@b.foot/]
