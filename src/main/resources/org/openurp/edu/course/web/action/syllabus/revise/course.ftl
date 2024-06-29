[#ftl/]
[@b.head/]
  <style>
    .card-header{
      padding:.5rem 1.25rem;
    }
  </style>
<div class="container">

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

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">教学大纲</h4>
       [@b.a class="btn btn-primary btn-sm" href="!editNew?course.id=" + course.id + "&locale=en_US"  target="_blank" style="float:right;margin-left:20px"]新增英文大纲[/@]
       [@b.a class="btn btn-primary btn-sm" href="!editNew?course.id=" +course.id target="_blank" style="float:right"]新增中文大纲[/@] &nbsp;
    </div>
      <div class="card-body" style="padding-top: 0px;">
       <table class="table table-hover table-sm table-striped">
           [#list syllabuses as syllabus]
         <tr>
           <td>${syllabus.semester.schoolYear}学年${syllabus.semester.name}学期</td>
           <td>${locales.get(syllabus.docLocale)}</td>
           <td>${syllabus.writer.name}</td>
           <td>${syllabus.status}</td>
           <td>${syllabus.updatedAt?string('yyyy-MM-dd HH:mm')}</td>
           <td>
             [#if editables?seq_contains(syllabus.status)]
             [@b.a href="!edit?id=${syllabus.id}" target="_blank"]修改[/@]
             [@b.a href="!remove?id=${syllabus.id}" onclick="if(confirm('确定删除该教学大纲吗吗?')){return bg.Go(this,null)}else{return false;}"]删除[/@]
             [/#if]
           </td>
           <td>[@b.a href="!info?id=${syllabus.id}" target="_blank"]查看[/@]</td>
           <td>[@b.a href="!pdf?id=${syllabus.id}" target="_blank"]下载PDF[/@]</td>
         </tr>
           [/#list]
       </table>
      </div>
  </div>

</div>
[@b.foot/]
