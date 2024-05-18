  [@b.form theme="list" action="!saveDesign" target="_self"]
    [@b.textfield label="Name" name="design.name" value=design.name! required="true"/]
    [@b.textarea label="Contents" name="design.contents" rows="12" cols="80" value=design.contents! required="true" maxlength="3000"/]
    [#assign caseAndExperiments=""/]
    [#if syllabus.cases?size>0][#assign caseAndExperiments=caseAndExperiments+"hasCase"/][/#if]
    [#if syllabus.experiments?size>0][#assign caseAndExperiments=caseAndExperiments+",hasExperiment"/][/#if]
    [@b.checkboxes label="Case and experiments" items="hasCase:Case teaching,hasExperiment:Experiment teaching" onclick="toggleCaseAndExperiment(this)" values=caseAndExperiments name="caseAndExperiments"/]
    [#assign caseStyle][#if syllabus.cases?size==0]display:none[/#if][/#assign]
    [@b.field label="Cases" id="hasCase_field" style=caseStyle]
      [#assign cases = {}/]
      [#list syllabus.cases?sort_by("idx") as c]
        [#assign cases=cases+{'${c.idx}':c}/]
      [/#list]
      <ul style="margin-left: 6.25rem;padding-left: 1rem;">
      [#list 0..9 as i]
        <ol><label>${i+1}：</label><input type="text" placeholder="Case No.${i+1}'s name" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
      [/#list]
      </ul>
    [/@]
    [#assign expStyle][#if syllabus.experiments?size==0]display:none[/#if][/#assign]
    [@b.field label="Experiments" id="hasExperiment_field" style=expStyle]
      [#assign exps = {}/]
      [#list syllabus.experiments?sort_by("idx") as c]
        [#assign exps=exps+{'${c.idx}':c}/]
      [/#list]
      <ul style="margin-left: 6.25rem;padding-left: 1rem;">
      [#list 0..9 as i]
        <ol>
        <label>${i+1}：</label><input type="text" placeholder="Experiment ${i+1}'s name" name="experiment${i}.name" value="${(exps[i?string].name)!}" style="width:300px"/>
        <select name="experiment${i}.experimentType.id" >
          [#list experimentTypes as et]
          <option value="${et.id}" [#if ((exps[i?string].experimentType.id)!0)==et.id]checked="checked"[/#if]>${et.name}</option>
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
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=topics" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
      [@b.submit value="Save and move to the next step" /]
    [/@]
  [/@]
