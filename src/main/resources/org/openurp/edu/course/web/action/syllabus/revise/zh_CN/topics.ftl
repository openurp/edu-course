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
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 3/]
[#list syllabus.topics?sort_by("idx") as topic]
  [#include "topicInfo.ftl"/]
[/#list]
[@b.div id="div_topic_new"]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
    <div class="card card-info card-primary card-outline">
        [@b.card_header]
          <div class="card-title"><i class="fas fa-edit"></i>&nbsp;新增教学内容</div>
          [@b.card_tools]
            <button type="button" class="btn btn-tool" data-card-widget="collapse">
              <i class="fas fa-plus"></i>
            </button>
          [/@]
        [/@]
        <div class="card-body" style="display:none">
          [@b.form theme="list" action="!saveTopic"]
            [@b.textfield label="主题名" name="topic.name" required="true"/]
            [@b.textfield label="主题顺序" name="topic.idx"  value=(syllabus.topics?size+1) required="true"/]
            [@b.textarea label="教学内容" name="topic.contents" rows="4" cols="80" required="true"/]
            [#list topicLabels as label]
              [@b.textarea label=label.name name="label"+label.id rows="3" cols="80" required="true"/]
            [/#list]
            [@b.select label="对应课程目标" name="objective.id" items=syllabus.objectives required="false" multiple="true"/]
            [@b.select label="教学方法" name="teachingMethod.id" items=teachingMethods required="false" multiple="true"/]
            [@b.field label="分类课时"]
               [#list teachingNatures as ht]
                <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
                <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="">课时
                <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="">实践周
               [/#list]
            [/@]
            [@b.formfoot]
              <input type="hidden" name="course.id" value="${course.id}"/>
              <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
              [@b.submit value="保存" /]
            [/@]
          [/@]
        </div>
    </div>
  </div>
[/@]

[@b.form name="dummy" action="!nextStep" theme="list"]
  [@b.formfoot]
    <input type="hidden" name="course.id" value="${course.id}"/>
    <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
    <input type="hidden" name="step" value="design"/>
    <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
    [@b.submit value="下一步" /]
  [/@]
[/@]
</div>
[@b.foot/]
