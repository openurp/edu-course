[#assign sectionIndexNames= ["一","二","三","四","五","六","七","八","九","十","十一","十二","十三","十四","十五"] /]
[@b.messages slash="3"/]
<div class="card">
  <div class="card-header">
      <h1 style="display:inline;">
        <a class="q-anchor q-heading-anchor" name="lesson${design.idx}"></a>第${design.idx}次课
      </h1>
      <span style="font-weight:bold;">${design.subject}</span>
      <div class="card-tools">
       [@b.a class="btn btn-outline-primary btn-sm" href="!editDesign?program.id=${design.program.id}&design.id=${design.id}"]<i class="fa-solid fa-edit"></i>修改[/@]
       [@b.a class="btn btn-outline-primary btn-sm" href="!designReport?program.id=${design.program.id}&design.id=${design.id}" target="_blank"]<i class="fa-solid fa-print"></i>打印预览[/@]
       [@b.a class="btn btn-outline-primary btn-sm" href="!designPdf?program.id=${design.program.id}&design.id=${design.id}" target="_blank"]<i class="fa-solid fa-file-pdf"></i>下载PDF[/@]
      </div>
  </div>

  [@b.div class="card-body"]
    <dl>
      <dt>教学目标</dt>
      <dd>${design.get('target')!}</dd>
      <dt>教学重点</dt>
      <dd>${design.get('emphasis')!}</dd>
      <dt>教学难点</dt>
      <dd>${design.get('difficulties')!}</dd>
      [#if design.get('resources')??]
      <dt>教学资源</dt>
      <dd>${design.get('resources')!}</dd>
      [/#if]
      [#if design.get('values')??]
      <dt>课程思政融入点</dt>
      <dd>${design.get('values')!}</dd>
      [/#if]
      [#if design.homework??]
      <dt>课后作业</dt>
      <dd>${design.homework}</dd>
      [/#if]
      <dt>教学内容与过程设计</dt>
    </dl>

    [#list design.sections?sort_by("idx") as section]
    <div class="card" style="margin-bottom:5px;">
      <div class="card-header" style="padding-top:2px;padding-bottom:2px;">
        <div class="card-title">${sectionIndexNames[section.idx-1]}、${section.title}</div>
        <div class="card-tools">${section.duration}分钟</div>
      </div>
      <div class="card-body">
        <p style="font-weight:bold;">教学内容提要：</p>${section.summary}
        <p style="font-weight:bold;">教学过程设计（包括教学方法与手段、学生学习活动、教师支持活动等）:</p>${section.details}
      </div>
    </div>
    [/#list]
  [/@]
</div>