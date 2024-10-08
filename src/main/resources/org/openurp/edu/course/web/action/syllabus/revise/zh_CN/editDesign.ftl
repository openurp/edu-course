  [@b.form theme="list" action="!saveDesign" target="_self" onsubmit="checkCaseAndExperiment"]
    [@b.textfield label="教学法名称" name="design.name" value=design.name! required="true"/]
    [@b.textarea label="教学法内容" name="design.contents" rows="12" cols="80" value=design.contents! required="true"/]
    [#assign caseAndExperiments=""/]
    [#if design.hasCase][#assign caseAndExperiments=caseAndExperiments+"hasCase"/][/#if]
    [#if design.hasExperiment][#assign caseAndExperiments=caseAndExperiments+",hasExperiment"/][/#if]
    [@b.checkboxes label="案例和实验" items="hasCase:有案例,hasExperiment:有实验" onclick="toggleCaseAndExperiment(this)" values=caseAndExperiments name="caseAndExperiments"/]
    [#assign caseStyle][#if !design.hasCase]display:none[/#if][/#assign]
    [@b.field label="案例" id="hasCase_field" style=caseStyle]
      [#assign cases = {}/]
      [#list syllabus.cases?sort_by("idx") as c]
        [#assign cases=cases+{'${c.idx}':c}/]
      [/#list]
      <ul style="margin-left: 6.25rem;padding-left: 1rem;">
      [#list 0..14 as i]
        <ol><label>${i+1}：</label><input type="text" placeholder="案例${i+1}的名称" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
      [/#list]
      </ul>
    [/@]
    [#assign expStyle][#if !design.hasExperiment]display:none[/#if][/#assign]
    [@b.field label="实验项目" id="hasExperiment_field" style=expStyle]
      [#assign exps = {}/]
      [#list syllabus.experiments?sort_by("idx") as c]
        [#assign exps=exps+{'${c.idx}':c}/]
      [/#list]
      <ul style="margin-left: 6.25rem;padding-left: 1rem;">
      [#list 0..14 as i]
        <ol>
        <label>${i+1}：</label><input type="text" placeholder="实验项目${i+1}的名称" name="experiment${i}.name" value="${(exps[i?string].name)!}" style="width:300px"/>
        <input type="text" name="experiment${i}.creditHours" style="width:60px" value="${(exps[i?string].creditHours)!}" placeholder="学时"/>
        <select name="experiment${i}.experimentType.id" >
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
      <input type="hidden" name="design.id" value="${design.id}"/>
      [@b.submit value="保存" /]
    [/@]
  [/@]
