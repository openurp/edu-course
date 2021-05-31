[#ftl/]
[@b.head/]
[@b.toolbar title="课程简介"/]
<div class="container">
<table class="infoTable">
  <tr>
    <td class="title"  width="20%">代码:</td>
    <td class="content">${course.code}</td>
    <td class="title"  width="20%">名称:</td>
    <td class="content">${course.name}</td>
  </tr>
  <tr>
    <td class="title">学分:</td>
    <td class="content">${course.credits!}</td>
    <td class="title">学时:</td>
    <td class="content">${course.creditHours!}</td>
  </tr>
  <tr>
    <td class="title">开课院系:</td>
    <td class="content">${(course.department.name)!}</td>
    <td class="title">建议课程类别:</td>
    <td class="content">${(course.courseType.name)!}</td>
  </tr>
   <tr>
    <td class="title">课程种类:</td>
    <td class="content">${(course.category.name)!}</td>
    <td class="title">考试方式:</td>
    <td class="content">${(course.examMode.name)!}</td>
  </tr>
   <tr>
    <td class="title">中文简介:</td>
    <td class="content" colspan="3"><pre>${(profile.description)!}</pre></td>
  </tr>
   <tr>
    <td class="title">英文简介:</td>
    <td class="content" colspan="3"><pre>${(profile.enDescription)!}</pre></td>
  </tr>
</table>

<div style="text-align:center">
  [@b.a class="btn btn-primary" href="!edit?id=" +course.id role="button"]修改[/@]
</div>

</div>
[@b.foot/]
