[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 4/]
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
            [#list 0..9 as i]
              <ol><label>${i+1}：</label><input type="text" placeholder="案例${i+1}的名称" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
            [/#list]
            </ul>
          [/@]
          [@b.field label="实验" id="hasExperiment_field"  style="display:none"]
            [#assign exps = {}/]
            [#list syllabus.experiments?sort_by("idx") as c]
              [#assign exps=exps+{'${c.idx}':c}/]
            [/#list]
            <ul style="margin-left: 6.25rem;padding-left: 1rem;">
            [#list 0..9 as i]
              <ol>
              <label>${i+1}：</label><input type="text" placeholder="实验${i+1}的名称" name="experiment${i}.name" value="${(exps[i?string].name)!}" style="width:300px"/>
              <select name="experiment${i}.experimentType.id">
                [#list experimentTypes as et]
                <option value="${et.id}" [#if ((exps[i?string].experimentType.id)!0)==et.id]checked="checked"[/#if]>${et.name}</option>
                [/#list]
              </select>
              <div class="btn-group btn-group-toggle" data-toggle="buttons" style="height: 1.5625rem;">
                  <label style="font-size:0.8125rem !important;padding:2px 8px 0px 8px;" class="btn btn-outline-secondary btn-sm [#if !((exps[i?string].online)!false)]active[/#if]">
                  <input type="radio" name="experiment${i}.online" id="exp${i}_online_0" empty="..." value="0" [#if !((exps[i?string].online)!false)]checked=""[/#if]>线下实验
                </label>
                  <label style="font-size:0.8125rem !important;padding:2px 8px 0px 8px;" class="btn btn-outline-secondary btn-sm [#if ((exps[i?string].online)!false)]active[/#if]">
                  <input type="radio" name="experiment${i}.online" id="exp${i}_online_1" empty="..." value="1" [#if ((exps[i?string].online)!false)]checked=""[/#if]>线上实验
                </label>
              </div>
              </ol>
            [/#list]
            </ul>
          [/@]
          [@b.formfoot]
            <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
            [@b.submit value="保存" /]
          [/@]
        [/@]
      </div>
    </div>
  </div>
  <script>
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
    [@b.a href="!assesses?syllabus.id=${syllabus.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-right fa-sm"></i>下一步[/@]
  [/@]
[/@]
</div>
[@b.foot/]
