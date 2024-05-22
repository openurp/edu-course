  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">${course.code} ${course.name}</h4>
      [#--[@b.a class="btn btn-primary btn-sm" href="!edit?id=" +course.id style="float:right"]修改[/@]--]
    </div>
    <table class="infoTable">
      <tr>
        <td class="title"  width="20%">代码:</td>
        <td class="content">${course.code}</td>
        <td class="title"  width="20%">名称:</td>
        <td class="content">${course.name}</td>
      </tr>
      <tr>
        <td class="title">学分:</td>
        <td class="content">${course.defaultCredits!}</td>
        <td class="title">学时:</td>
        <td class="content">${course.creditHours!}</td>
      </tr>
      <tr>
        <td class="title">开课院系:</td>
        <td class="content">${(course.department.name)!}</td>
        <td class="title">建议课程类别:</td>
        <td class="content">${(course.courseType.name)!}</td>
      </tr>
    </table>
  </div>
