[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course Syllabus Edit Form"]
  bar.addClose("Close");
[/@]
[#include "step.ftl"/]
[@displayStep 1/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [#assign placeholders=["思想政治素质目标","诚信品质"]/]
  [@b.form theme="list" action="!saveObjectives"]
    [@b.textarea label="Course introduction and objectives" name="syllabus.description" value=syllabus.description! cols="100" rows="15"
      maxlength="4000"]
      <div style="display:inline-block;max-width:155px;">${tips['syllabus.description']!}</div>
    [/@]
    [@b.textarea label="Course leading value" name="values" value="${(syllabus.getText('values').contents)!}" cols="100" rows="8" placeholder="经世济民、诚信服务等职业素养，课程根据思政教育和课程思政的安排，在本课程中融入的课程思政教学内容。"
      maxlength="2000" required="true"]
      <div style="display:inline-block;max-width:155px;">${tips['values']!}</div>
    [/@]
    [#list 1..6 as i]
    [@b.textarea label="Course objective CO"+i name="CO"+i value="${(syllabus.getObjective('CO'+i).contents)!}" cols="100" rows="4"
      maxlength="1000" comment="Within 1000 characters" placeholder=((placeholders[i-1])!"") /]
    [/#list]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="requirements"/>
      [@b.a href="!edit?syllabus.id=${syllabus.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
      [@b.submit value="Save and move to the next step" /]
    [/@]
  [/@]
  </div>
</div>

[#--
价值目标最少几个？
--]
[@b.foot/]
