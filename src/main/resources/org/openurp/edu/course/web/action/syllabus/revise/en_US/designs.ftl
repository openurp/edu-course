[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course Syllabus Edit Form"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  4/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
    [#list syllabus.designs?sort_by("idx") as design]
      [#include "designInfo.ftl"/]
    [/#list]
    <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title"><i class="fas fa-edit"></i>&nbsp;New teaching method -- No.${(syllabus.designs?size+1)}</div>
        [@b.card_tools]
          <button type="button" class="btn btn-tool" data-card-widget="collapse">
            <i class="fas fa-plus"></i>
          </button>
        [/@]
      [/@]
      <div class="card-body" [#if syllabus.designs?size>0]style="display:none"[/#if]>
        [@b.form theme="list" action="!saveDesign"]
          [@b.textfield label="Name" name="design.name" value="" required="true"/]
          [@b.textarea label="Contents" name="design.contents" rows="12" cols="80" value="" required="true" maxlength="3000"/]
          [#assign caseAndExperiments=""/]
          [@b.checkboxes label="Case and experiments" items="hasCase:Case teaching,hasExperiment:Experiment teaching" onclick="toggleCaseAndExperiment(this)" name="caseAndExperiments"/]
          [@b.field label="Cases" id="hasCase_field"]
            [#assign cases = {}/]
            [#list syllabus.cases?sort_by("idx") as c]
              [#assign cases=cases+{'${c.idx}':c}/]
            [/#list]
            <ul style="margin-left: 10rem;padding-left: 0.5rem;">
            [#list 0..14 as i]
              <ol><label>${i+1}：</label><input type="text" placeholder="Case No.${i+1}'s name" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
            [/#list]
            </ul>
          [/@]
          [@b.field label="Experiments" id="hasExperiment_field"  style="display:none"]
            [#assign exps = {}/]
            [#list syllabus.experiments?sort_by("idx") as c]
              [#assign exps=exps+{'${c.idx}':c}/]
            [/#list]
            <ul style="margin-left: 10rem;padding-left: 0.5rem;">
            [#list 0..9 as i]
              <ol>
              <label>${i+1}：</label><input type="text" placeholder="Experiment ${i+1}'s name" name="experiment${i}.name" value="${(exps[i?string].name)!}" style="width:300px"/>
              <input type="text" name="experiment${i}.creditHours" style="width:60px"  value="${(exps[i?string].creditHours)!}" placeholder="学时"/>
              <select name="experiment${i}.experimentType.id">
                [#list experimentTypes as et]
                <option value="${et.id}" [#if ((exps[i?string].experimentType.id)!0)==et.id]selected="selected"[/#if]>${et.name}</option>
                [/#list]
              </select>
              <div class="btn-group btn-group-toggle" data-toggle="buttons" style="height: 1.5625rem;">
                  <label style="font-size:0.8125rem !important;padding:2px 8px 0px 8px;" class="btn btn-outline-secondary btn-sm [#if !((exps[i?string].online)!false)]active[/#if]">
                  <input type="radio" name="experiment${i}.online" id="exp${i}_online_0" empty="..." value="0" [#if !((exps[i?string].online)!false)]checked=""[/#if]>线下课堂教学实验
                </label>
                  <label style="font-size:0.8125rem !important;padding:2px 8px 0px 8px;" class="btn btn-outline-secondary btn-sm [#if ((exps[i?string].online)!false)]active[/#if]">
                  <input type="radio" name="experiment${i}.online" id="exp${i}_online_1" empty="..." value="1" [#if ((exps[i?string].online)!false)]checked=""[/#if]>线上虚拟仿真实验
                </label>
              </div>
              </ol>
            [/#list]
            </ul>
          [/@]
          [@b.formfoot]
            <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
            [@b.submit value="Save" onsubmit="checkCaseAndExperiment" /]
          [/@]
        [/@]
      </div>
    </div>
  </div>
  <script>
     function checkCaseAndExperiment(form){
       var checks = form['caseAndExperiments'];
       var hasCase=false;
       var hasExperiment=false;
       for(var i=0;i< checks.length;i++){
         if(checks[i].checked){
           if(checks[i].value=='hasCase'){
             hasCase=true;
           }else{
             hasExperiment=true;
           }
         }
       }
       if(hasCase){
         var caseCnt =0;
         for(var i=0; i<=9;i++){
           if(form["case"+i+".name"].value){
             caseCnt +=1;
           }
         }
         if(caseCnt==0){
           alert("请至少填写一个案例");
           return false;
         }
       }
       if(hasExperiment){
         var totalHours = 0;
         var experimentCnt = 0;
         var missingHoursExperiments = [];
         for(var i=0; i<=9;i++){
           if(form["experiment"+i+".name"].value){
             var hours = parseInt(form["experiment"+i+".creditHours"].value||"0");
             if(hours<=0){
               missingHoursExperiments.push(i+1);
             }
             experimentCnt += 1;
             totalHours += hours;
           }
         }
         if(experimentCnt==0){
           alert("请至少填写一个实验项目");
           return false;
         }
         if(missingHoursExperiments.length>0){
           alert("实验项目"+missingHoursExperiments.join(',')+"缺少实验学时");
           return false;
         }
         [#assign practicalHours = 0/]
         [#list syllabus.hours as h][#if h.nature.id=9][#assign practicalHours = practicalHours + h.creditHours/][/#if][/#list]
         if(totalHours > ${practicalHours}){
            alert("实验项目总学时为"+totalHours+",不应超过课程实践${practicalHours}学时");
            return false;
         }
       }
       return true;
     }
    function toggleCaseAndExperiment(elem){
      if(elem.checked){
        document.getElementById(elem.value+"_field").style.display="";
      }else{
        document.getElementById(elem.value+"_field").style.display="none";
      }
    }
  </script>
[@b.form name="dummy" action="!nextStep" theme="list"]
  [@b.formfoot]
    <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
    <input type="hidden" name="step" value="assess"/>
    [@b.a href="!edit?syllabus.id=${syllabus.id}&step=topics" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
    [#if syllabus.designs?size>0]
    [@b.a href="!assesses?syllabus.id=${syllabus.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-right fa-sm"></i>Next step[/@]
    [/#if]
  [/@]
[/@]
</div>
[@b.foot/]
