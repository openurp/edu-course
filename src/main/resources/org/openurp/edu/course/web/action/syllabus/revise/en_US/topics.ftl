[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course Syllabus Edit Form"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 3/]

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
          <div class="card-title"><i class="fas fa-edit"></i>&nbsp;New Topic--Index ${(syllabus.topics?size+1)}</div>
          [@b.card_tools]
            <button type="button" class="btn btn-tool" data-card-widget="collapse">
              <i class="fas fa-plus"></i>
            </button>
          [/@]
        [/@]
        <div class="card-body" style="display:none">
          [@b.form theme="list" action="!saveTopic" target="_self"]
            [@b.textfield label="Topic Name" name="topic.name" required="true"  style="width:500px" comment="Chapter 1: xxx "/]
            [@b.textarea label="Contents" name="topic.contents" rows="5" cols="80" required="true" maxlength="3000"/]
            [#list topicLabels as label]
              [@b.textarea label=label.enName name="element"+label.id rows="3" cols="80" required="true" maxlength="2000"/]
            [/#list]
            [@b.checkboxes label="Teaching methods11" name="teachingMethod" items=teachingMethods required="true" min="1"/]
            [@b.field label="Teaching hours"]
              [#list syllabus.teachingNatures as ht]
                <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
                <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value=""> hours
                [#if ((syllabus.getHour(ht).weeks)!0)>0]<input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value=""> weeks[/#if]
              [/#list]
               <label for="learning_p">Autonomous learning hours</label>
               <input name="topic.learningHours" style="width:30px" id="learning_p" value=""> hours
            [/@]
            [@b.checkboxes label="Course objective" name="objective.id" items=syllabus.objectives required="false"/]
            [@b.formfoot]
              <input type="hidden" name="course.id" value="${course.id}"/>
              <input type="hidden" name="topic.idx" value="${(syllabus.topics?size+1)}"/>
              <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
              [@b.submit value="Save" /]
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
    [@b.a href="!edit?syllabus.id=${syllabus.id}&step=outcomes" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
    [#if syllabus.topics?size>0][@b.submit value="Move to the next step" /][/#if]
  [/@]
[/@]
</div>
[@b.foot/]
