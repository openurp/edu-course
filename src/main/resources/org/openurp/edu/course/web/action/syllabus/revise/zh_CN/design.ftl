[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 4/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveDesign"]
    [@b.textarea label="学验并重的教学设计" name="design" rows="10" cols="80" value=(syllabus.getText('design').contents)! required="true"/]

    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      [#if syllabus.id??]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [/#if]
      <input type="hidden" name="step" value="assess"/>
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
