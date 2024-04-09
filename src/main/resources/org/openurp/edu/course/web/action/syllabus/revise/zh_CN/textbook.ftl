[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 6/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveTextbook"]
    [@b.field label="课程"]${course.code} ${course.name}[/@]
    [@b.field  label="学分学时"]${course.defaultCredits!}学分 ${course.creditHours!}学时 每周${course.weekHours}课时[/@]
    [@b.select name="textbook.id" label="教材" required="false" style="width:500px;" items=textbooks multiple="true" option="id,name" empty="..."/]
    [@b.textarea name="syllabus.bibliography" label="参考书目" value=syllabus.bibliography! required="false" rows="4" cols="80"/]
    [@b.textarea name="syllabus.materials" label="其他教学资源" value=syllabus.materials! required="false" rows="4" cols="80"/]
    [@b.textfield name="syllabus.website" label="课程网站" value=syllabus.website! required="false" maxlength="300" style="width:300px"/]
    [@b.formfoot]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
      [@b.submit value="保存" /]
      [@b.submit value="提交审批" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
