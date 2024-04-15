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
<div class="alert alert-warning">
  [#list syllabus.hours as h]
    [#assign topicHour=0/]
    [#list syllabus.topics as topic]
      [#assign topicHour=topicHour+((topic.getHour(h.nature).creditHours)!0)/]
    [/#list]
    [#if topicHour != h.creditHours]
      课程要求${h.nature.name}${h.creditHours}课时，教学内容累计${topicHour}课时，请检查。
    [/#if]
  [/#list]
</div>

<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
    [#list syllabus.topics?sort_by("idx") as topic]
      [#include "topicInfo.ftl"/]
    [/#list]
    <div class="card card-info card-primary card-outline">
        [@b.card_header]
          <div class="card-title"><i class="fas fa-edit"></i>&nbsp;新增教学内容--序号${(syllabus.topics?size+1)}</div>
          [@b.card_tools]
            <button type="button" class="btn btn-tool" data-card-widget="collapse">
              <i class="fas fa-plus"></i>
            </button>
          [/@]
        [/@]
        <div class="card-body" style="display:none">
          [@b.form theme="list" action="!saveTopic" target="_self"]
            [@b.textfield label="主题名" name="topic.name" required="true"  style="width:300px" comment="第几章 XXXXXX"/]
            [@b.textarea label="教学内容" name="topic.contents" rows="5" cols="80" required="true"/]
            [#list topicLabels as label]
              [@b.textarea label=label.name name="element"+label.id rows="2" cols="80" required="true"/]
            [/#list]
            [@b.checkboxes label="教学方法1" name="teachingMethod.id" items=teachingMethods required="true"/]
            [@b.field label="课时分布"]
              [#list syllabus.teachingNatures as ht]
                <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
                <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="">课时
                [#if ((syllabus.getHour(ht).weeks)!0)>0]<input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="">实践周[/#if]
              [/#list]
               <label for="learning_p">自主学习</label>
               <input name="topic.learningHours" style="width:30px" id="learning_p" value="">课时
            [/@]
            [@b.checkboxes label="对应课程目标" name="objective.id" items=syllabus.objectives required="false"/]
            [@b.formfoot]
              <input type="hidden" name="course.id" value="${course.id}"/>
              <input type="hidden" name="topic.idx" value="${(syllabus.topics?size+1)}"/>
              <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
              [@b.submit value="保存" /]
            [/@]
          [/@]
        </div>
    </div>
  </div>

[@b.form name="dummy" action="!nextStep" theme="list"]
  [@b.formfoot]
    <input type="hidden" name="course.id" value="${course.id}"/>
    <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
    <input type="hidden" name="step" value="designs"/>
    [@b.a href="!edit?syllabus.id=${syllabus.id}&step=outcomes" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
    [@b.submit value="下一步" /]
  [/@]
[/@]
</div>
[@b.foot/]
