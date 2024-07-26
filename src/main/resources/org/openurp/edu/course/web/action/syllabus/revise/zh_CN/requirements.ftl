[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 2/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveRequirements"]
    [@b.field label="填写说明"]
    <div style="margin-left: 10rem;" class="text-muted">
      <p>
        1.通识课、数学课、学科专业基础课（含跨学科跨专业选修课）请从“人才培养方案指导意见附表1：通识课、数学课、学科基础课与毕业要求对应关系”中通
        用知识、能力、素质中选择课程需要支撑的毕业要求。通用知识、能力、素质全校统一分为 8 个方面，请不要改变顺序。
        例如某门课程支撑的是【思想政治素质】、【诚信品质】、【创新意识】，就仅保留这几项毕业要求（其他在本课程未支撑的毕业要求可以删除），并结合课
        程和该项毕业要求进行具体描述。同时，将毕业要求课程目标和毕业要求的对应关系和支撑矩阵.
      </p>
      <p style="margin-bottom:0px">
        2.专业课请根据专业培养方案设定的知识、能力、素质的毕业要求，选择课程需要支撑的毕业要求。
        例如某门课程支撑的是 【思想品质】、【团队合作】、【实践能力】就仅保留这几项毕业要求（其他在本课程未支撑的毕业要求可以删除），
        并结合将毕业要求分解给课程的培养要求进行具体描述。同时，将毕业要求课程目标和毕业要求的对应关系和支撑矩阵。
      </p>
    </div>
    [/@]
    [#list 1..12 as i]
    [@b.textfield name="R${i}" label="毕业要求R${i}" value=(requirements[i-1])! maxlength="20" style="width:400px" comment="word文档【】内的标题"/]
    [/#list]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="outcomes"/>
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=objectives" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit action="!saveRequirements?justSave=1"]<i class="fa-solid fa-floppy-disk"></i>保存[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
