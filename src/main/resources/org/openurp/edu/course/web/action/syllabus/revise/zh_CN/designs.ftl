[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
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
        <div class="card-title"><i class="fas fa-edit"></i>&nbsp;新增教学法--序号${(syllabus.designs?size+1)}</div>
        [@b.card_tools]
          <button type="button" class="btn btn-tool" data-card-widget="collapse">
            <i class="fas fa-plus"></i>
          </button>
        [/@]
      [/@]
      <div class="card-body" [#if syllabus.designs?size>0]style="display:none"[/#if]>
        [@b.form theme="list" action="!saveDesign"]
          [@b.textfield label="教学法名称" name="design.name" value="" required="true" comment="标题中不要添加序号"/]
          [@b.textarea label="教学法内容" name="design.contents" rows="12" cols="80" value="" required="true"/]
          [#assign caseAndExperiments=""/]
          [@b.checkboxes label="案例和实验" items="hasCase:有案例,hasExperiment:有实验" onclick="toggleCaseAndExperiment(this)" name="caseAndExperiments"/]
          [@b.field label="案例" id="hasCase_field"]
            [#assign cases = {}/]
            [#list syllabus.cases?sort_by("idx") as c]
              [#assign cases=cases+{'${c.idx}':c}/]
            [/#list]
            <ul style="margin-left: 6.25rem;padding-left: 1rem;">
            [#list 1..15 as i]
              <ol><label>${i}：</label><input type="text" placeholder="案例${i}的名称" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
            [/#list]
            </ul>
          [/@]
          [@b.field label="实验项目" id="hasExperiment_field" style="display:none"]
            [#assign exps = {}/]
            [#list syllabus.experiments?sort_by("idx") as c]
              [#assign exps=exps+{'${c.idx}':c.experiment}/]
            [/#list]
            <div style="display: inline-block;">
              修改和新增项目可以从<a href='${b.url("!experiments?syllabus.id=" + syllabus.id)}'
                 data-toggle="modal" data-target="#experimentDialog">课程项目库</a>进行维护,然后添加到此处。
              <ul style="padding-left: 1rem;">
              [#list 1..15 as i]
                <ol style="padding-left:0rem;">
                <label>${i}：</label>
                [@b.select name="experiment${i}.id" style="width:400px" href="!experimentData.json?q={term}&course.id="+syllabus.course.id option="id,description" value=(exps[i?string])! theme="html" chosenMin="10"/]
                </ol>
              [/#list]
              </ul>
            </div>
          [/@]
          [@b.formfoot]
            <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
            [@b.submit value="保存" onsubmit="checkCaseAndExperiment"/]
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
         for(var i=1; i<=15;i++){
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
         var experimentIds=[];
         for(var i=1; i<=15;i++){
           if(form["experiment"+i+".id"].value){
             experimentIds.push(form["experiment"+i+".id"].value);
           }
         }
         if(experimentIds.length==0){
           alert("请至少填写一个实验项目");
           return false;
         }
         var totalHours = 0;
         [#assign practicalHours = 0/]
         [#list syllabus.hours as h][#if h.nature.id=9][#assign practicalHours = practicalHours + h.creditHours/][/#if][/#list]
         $.ajaxSettings.async = false;
         $.get("${b.url('!experimentCreditHours')}?experiment.ids="+experimentIds.join(","), function(response) {
           totalHours = Number.parseFloat(response);
         });
         $.ajaxSettings.async = true;
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
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=topics" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [#if syllabus.designs?size>0]
      [@b.a href="!assesses?syllabus.id=${syllabus.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-right fa-sm"></i>下一步[/@]
      [/#if]
    [/@]
  [/@]

  [@b.dialog title="课程项目库"  id="experimentDialog"/]
</div>
[@b.foot/]
