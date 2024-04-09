[#ftl]
[@b.head/]
[@b.toolbar title="课程群组信息"]
  bar.addBack();
[/@]
[#macro displayTeacher t]
  <td [#if t.endOn??]class="text-muted"[/#if]>${t.code}</td>
  <td [#if t.endOn??]class="text-muted"[/#if]>${t.name}[#if t.gender.id!=1](${t.gender.name})[/#if]</td>
  <td [#if t.endOn??]class="text-muted"[/#if]>${(t.staff.title.name)!}</td>
  <td [#if t.endOn??]class="text-muted"[/#if]>${t.department.name}</td>
[/#macro]
<div class="container">
  <h5>${courseTask.code} ${courseTask.name}</h5>
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    <table class="infoTable">
      <tr>
        <td class="title" width="20%">代码:</td>
        <td class="content">${courseTask.code}</td>
        <td class="title" width="20%">名称:</td>
        <td class="content">${courseTask.name}</td>
      </tr>
      <tr>
        <td class="title">英文名:</td>
        <td class="content">${courseTask.enName!}</td>
        <td class="title">院系:</td>
        <td class="content">${(courseTask.department.name)!}</td>
      </tr>
      <tr>
        <td class="title">系/教研室:</td>
        <td class="content">${(courseTask.office.name)!}</td>
        <td class="title">负责人:</td>
        <td class="content">${(courseTask.director.name)!}</td>
      </tr>
    </table>
    [#if courseTask.teachers?size > 0]
    <table class="table table-hover table-sm table-striped">
       <thead style="text-align:center">
         <th>教师工号</th>
         <th>教师姓名</th>
         <th>职称</th>
         <th>所在部门</th>
         <th>教师工号</th>
         <th>教师姓名</th>
         <th>职称</th>
         <th>所在部门</th>
      </thead>
      <tbody>
      [#assign teacherCountHalf = (courseTask.teachers?size+1)/2?int/]
      [#assign teacherColumns  = courseTask.teachers?sort_by("beginOn")?chunk(teacherCountHalf)/]
      [#list 0..teacherCountHalf-1 as i]
      <tr style="text-align:center">
        [@displayTeacher teacherColumns[0][i]/]
        [#if teacherColumns[1][i]??]
        [@displayTeacher teacherColumns[1][i]/]
        [#else]
        <td></td><td></td><td></td><td></td>
        [/#if]
      </tr>
      [/#list]
    </table>
    [/#if]
    <table class="table table-hover table-sm table-striped">
       <thead style="text-align:center">
         <th>课程代码</th>
         <th>课程名称</th>
         <th>开课院系</th>
         <th>建议课程类别</th>
         <th>学分</th>
         <th>学时</th>
         <th>考查方式</th>
         <th>有效期</th>
      </thead>
      <tbody>
      [#list courseTask.courses as c]
      <tr style="text-align:center">
        <td>${c.code}</td>
        <td>${c.name}</td>
        <td>${c.department.name}</td>
        <td>${c.courseType.name}</td>
        <td>${c.defaultCredits}</td>
        <td>${c.creditHours}</td>
        <td>${(c.examMode.name)!}</td>
        <td>${c.beginOn}~${c.endOn!}</td>
      </tr>
      [/#list]
    </table>
  </div>

</div>
[@b.foot/]
