[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  3/]

[#if validateHourMessages?size>0]
<div class="alert alert-warning">
   [#list validateHourMessages as msg]${msg}<br>[/#list]
</div>
[/#if]

<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
    [#list syllabus.topics?sort_by("idx") as topic]
      [#include "topicInfo.ftl"/]
    [/#list]
    <div class="card card-info card-primary card-outline">
        [@b.card_header]
          <div class="card-title"><i class="fas fa-edit"></i>&nbsp;新增教学内容--序号${(syllabus.topics?size+1)}</div>
          [@b.card_tools]
            <button type="button" class="btn btn-tool" [#if validateHourMessages?size==0]data-card-widget="collapse"[/#if]>
              <i class="fas fa-plus"></i>
            </button>
          [/@]
        [/@]
        <div class="card-body" style="padding-top: 0px;[#if validateHourMessages?size==0]display:none;[/#if]" id="new_topic_card">
          [@b.form theme="list" name="newTopicForm" action="!saveTopic" target="_self"]
            [@b.radios label="教学环节" name="topic.exam" value="0" items="0:课堂教学,1:考查考试" onclick="changeTopicExam(this.value);"/]
            [@b.textfield label="主题名" name="topic.name" required="true"  style="width:300px" comment="第几章 XXXXXX"/]
            [@b.textarea label="教学内容" name="topic.contents" rows="5" cols="80" required="true" maxlength="3000"/]
            [#list topicLabels as label]
              [@b.textarea label=label.name name="element"+label.id rows="2" cols="80" required="true" maxlength="2000"/]
            [/#list]
            [@b.checkboxes label="教学方法" name="teachingMethod" items=teachingMethods required="true" min="1"/]
            [@b.field label="学时分布"]
              [#list syllabus.teachingNatures as ht]
                <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
                <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="">学时
                [#if ((syllabus.getHour(ht).weeks)!0)>0]<input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="">周[/#if]
              [/#list]
               <label for="learning_p">自主学习</label>
               <input name="topic.learningHours" style="width:30px" id="learning_p" value="">学时
            [/@]
            [@b.checkboxes label="对应课程目标" name="objective.id" items=syllabus.objectives required="false"/]
            [@b.formfoot]
              <input type="hidden" name="course.id" value="${course.id}"/>
              <input type="hidden" name="topic.idx" value="${(syllabus.topics?size+1)}"/>
              <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
              [@b.submit value="保存" /]
            [/@]
            <script>
               function changeTopicExam(examValue){
                 bg.Go("${b.url("!newTopic?syllabus.id=${syllabus.id}")}&topic.exam="+examValue,"new_topic_card");
               }
            </script>
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
    [#if syllabus.topics?size>0][@b.submit value="下一步" /][/#if]
  [/@]
[/@]
</div>
[@b.foot/]
