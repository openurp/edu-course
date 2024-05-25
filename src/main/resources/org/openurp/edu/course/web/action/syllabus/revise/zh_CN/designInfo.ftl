[@b.div id="div_design_${design.id}"]
  <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title">${design.name}
        </div>
        [@b.card_tools]
         <div class="btn-group">
         [@b.a href="!editDesign?design.id=${design.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>修改[/@]
         [@b.a href="!removeDesign?design.id=${design.id}"  onclick="return confirm('确定删除该教学法?');"class="btn btn-sm btn-outline-danger"]<i class="fa fa-xmark"></i>删除[/@]
         </div>
        [/@]
       [/@]
      <div class="card-body">
        <p>${design.contents}</p>
        [#if design.hasCase]
        <ul>案例：
        [#list syllabus.cases as c]<li>${c.idx+1}:${c.name}</li>[/#list]
        </ul>
        [/#if]
        [#if design.hasExperiment]
        <ul>实验：
        [#list syllabus.experiments as e]<li>${e.idx+1}:${e.name} ${e.creditHours}学时 ${e.experimentType.name} ${e.online?string("线上虚拟仿真实验","线下课堂教学实验")}</li>[/#list]
        </ul>
        [/#if]
      </div>
  </div>
[/@]
