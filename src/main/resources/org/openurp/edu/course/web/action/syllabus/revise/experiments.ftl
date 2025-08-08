<div class="card card-info card-primary card-outline">
  <div class="card-header">
      <h4 class="card-title">${syllabus.course.name}所有实验项目(${experiments?size}个)</h4>
      <div class="card-tools">
        [@b.a class="btn btn-sm btn-outline-primary" href='!editExperiment?syllabus.id=' +syllabus.id]新增[/@] &nbsp;
      </div>
  </div>
  <div class="card-body" style="padding-top: 0px;">
  [@b.messages slash="3"/]
  [@b.grid items=experiments?sort_by("code") var="exp" theme="mini"]
    [@b.row]
      [@b.col property="code" title="实验编码"/]
      [@b.col property="name" title="实验名称"]
        [@b.a href='!editExperiment?experiment.id='+exp.id+'&syllabus.id='+syllabus.id]${exp.name}[/@]
      [/@]
      [@b.col property="category.name" title="实验类别"/]
      [@b.col property="experimentType.name" title="实验类型"/]
      [@b.col property="creditHours" title="学时"/]
      [@b.col property="groupStdCount" title="每组人数"/]
      [@b.col property="discipline.name" title="学科"/]
    [/@]
  [/@]
  </div>
</div>
