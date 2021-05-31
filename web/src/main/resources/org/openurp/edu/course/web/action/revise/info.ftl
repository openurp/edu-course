[#ftl/]
[@b.head/]
<div class="container">
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">${course.code} ${course.name}</h4>
      [@b.a class="btn btn-primary btn-sm" href="!edit?id=" +course.id style="float:right"]修改[/@]
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
    </table>
  </div>

    [#if profile??]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">课程介绍</h3>
    </div>
      <table class="infoTable">
      <tr>
        <td class="title" width="20%">课程简介:</td>
        <td class="content" colspan="3">
          <div style="white-space:normal; word-break:break-all;overflow:hidden;">${profile.description}</div>
        </td>
      </tr>
      [#if profile.enDescription??]
      <tr>
        <td class="title">英文简介:</td>
        <td class="content" colspan="3">
          <div style="white-space:normal; word-break:break-all;overflow:hidden;">${profile.enDescription}</div>
        </td>
      </tr>
      [/#if]
      [#if profile.prerequisites??]
      <tr>
        <td class="title">先修课程:</td>
        <td class="content" colspan="3">${profile.prerequisites}</td>
      </tr>
      [/#if]
      [#if profile.textbooks?? && course.textbooks?size==0]
      <tr>
        <td class="title">默认教材:</td>
        <td class="content" colspan="3">${profile.textbooks}</td>
      </tr>
      [/#if]
      [#if profile.materials??]
      <tr>
        <td class="title">辅助资料:</td>
        <td class="content" colspan="3">${profile.materials}</td>
      </tr>
      [/#if]
      [#if profile.majors?? && course.majors?size==0]
      <tr>
        <td class="title">适用专业:</td>
        <td class="content" colspan="3">${profile.majors}</td>
      </tr>
      [/#if]
      [#if profile.website??]
      <tr>
        <td class="title">课程网站地址:</td>
        <td class="content" colspan="3">${profile.website}</td>
      </tr>
      [/#if]
    </table>
  </div>
    [/#if]

  [#if syllabuses?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">教学大纲</h3>
    </div>
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead>
         <th>作者</th>
         <th>附件</th>
         <th>更新学期</th>
      </thead>
      <tbody >
      [#list syllabuses as syllabus]
      <tr>
        <td>${syllabus.author.name}</td>
        <td>[#list syllabus.attachments as a][@b.a href="!attachment?file.id="+a.id target="_blank"]下载&nbsp;[/@][/#list]</td>
        <td>${syllabus.semester.schoolYear} 学年 ${syllabus.semester.name} 学期</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]
</div>
[@b.foot/]
