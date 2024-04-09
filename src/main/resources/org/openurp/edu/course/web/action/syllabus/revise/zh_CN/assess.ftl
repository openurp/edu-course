[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
<style>
  fieldset.listset li > label.title{
    min-width: 10rem;
  }
</style>
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 5/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveAssess"]
    [@b.textfield name="grade${usualType.id}.scorePercent" label="平时成绩百分比" value=(syllabus.getAssessment(usualType,null).scorePercent)! comment="%"/]
    [@b.textfield name="grade${endType.id}.scorePercent" label="期末成绩百分比" value=(syllabus.getAssessment(endType,null).scorePercent)! comment="%"/]
    [@b.field label="期末对课程目标支撑比例"]
      [#list syllabus.objectives?sort_by("code") as co]
        <label for="end_co${co.id}">${co.code}</label><input name="end_co{co.id}" type="number" style="width:50px">
      [/#list]
    [/@]

    [#assign regularNames=["课堂表现","课外作业","章节测验","期中测验","案例分析"]/]
      [#list regularNames as rn]
        <div class="card card-info card-primary card-outline">
            [@b.card_header]
              <div class="card-title"><i class="fas fa-edit"></i>&nbsp;平时成绩--${rn}</div>
             [/@]
            <div class="card-body">
                <input type="hidden" name="grade${usualType.id}_${rn_index}.component" value="${rn}"/>
                [@b.textfield name="grade${usualType.id}_"+rn_index+".scorePercent" label="占平时成绩比例" value=(syllabus.getAssessment(usualType,rn).scorePercent)! comment="%"/]
                [@b.textfield name="grade${usualType.id}_"+rn_index+".assessCount" label="考核次数" value=(syllabus.getAssessment(usualType,rn).assessCount)! /]
                [@b.field label="对课程目标支撑比例"]
                  [#list syllabus.objectives?sort_by("code") as co]
                    <label for="usual_co${co.id}">${co.code}</label><input name="usual_co{co.id}" type="number" style="width:50px">
                  [/#list]
                [/@]
                [@b.editor name="grade${usualType.id}_"+rn_index+".details" label="评分标准" rows="7" cols="80" maxlength="2000" value=(syllabus.getAssessment(usualType,rn).details)! style="height:300px"/]
            </div>
        </div>
      [/#list]
    [@b.formfoot]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="textbook"/>
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
