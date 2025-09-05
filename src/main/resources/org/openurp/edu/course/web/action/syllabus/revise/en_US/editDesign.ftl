  [@b.form theme="list" action="!saveDesign" target="_self" onsubmit="checkCaseAndExperiment"]
    [@b.textfield label="Name" name="design.name" value=design.name! required="true"/]
    [@b.textarea label="Contents" name="design.contents" rows="12" cols="80" value=design.contents! required="true" maxlength="3000"/]
    [#assign caseAndExperiments=""/]
    [#if design.hasCase][#assign caseAndExperiments=caseAndExperiments+"hasCase"/][/#if]
    [#if design.hasExperiment][#assign caseAndExperiments=caseAndExperiments+",hasExperiment"/][/#if]
    [@b.checkboxes label="Case and experiments" items="hasCase:Case teaching,hasExperiment:Experiment teaching" onclick="toggleCaseAndExperiment(this)" values=caseAndExperiments name="caseAndExperiments"/]
    [#assign caseStyle][#if !design.hasCase]display:none[/#if][/#assign]
    [@b.field label="Cases" id="hasCase_field" style=caseStyle]
      [#assign cases = {}/]
      [#list syllabus.cases?sort_by("idx") as c]
        [#assign cases=cases+{'${c.idx}':c}/]
      [/#list]
      <ul style="margin-left: 6.25rem;padding-left: 1rem;">
      [#list 1..15 as i]
        <ol><label>${i}：</label><input type="text" placeholder="Case No.${i}'s name" name="case${i}.name" value="${(cases[i?string].name)!}" style="width:400px"/></ol>
      [/#list]
      </ul>
    [/@]
    [#assign expStyle][#if !design.hasExperiment]display:none[/#if][/#assign]
    [@b.field label="Experiments" id="hasExperiment_field" style=expStyle]
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
      <input type="hidden" name="design.id" value="${design.id}"/>
      [@b.submit value="Save" /]
    [/@]
  [/@]

[@b.foot/]
