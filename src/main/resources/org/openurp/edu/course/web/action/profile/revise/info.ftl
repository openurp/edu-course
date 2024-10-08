[#ftl/]
[@b.head/]
[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]<div class="container">[/#if]
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
        <td class="content">${course.defaultCredits!}</td>
        <td class="title">学时:</td>
        <td class="content">${course.creditHours!}</td>
      </tr>
      <tr>
        <td class="title">开课院系:</td>
        <td class="content">${(course.department.name)!}</td>
        <td class="title">课程类别:</td>
        <td class="content">${(course.courseType.name)!}</td>
      </tr>
       <tr>
        <td class="title">课程模块:</td>
        <td class="content">${(course.module.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(course.examMode.name)!}</td>
      </tr>
    </table>
  </div>

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">课程介绍</h3>
    </div>
    [#if profile??]
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
      [#if profile.majors??]
      <tr>
        <td class="title">适用专业:</td>
        <td class="content" colspan="3">${profile.majors!}</td>
      </tr>
      [/#if]
      [#if profile.website??]
      <tr>
        <td class="title">课程网站地址:</td>
        <td class="content" colspan="3">${profile.website}</td>
      </tr>
      [/#if]
    </table>
    [#else]
      <div class="alert alert-default-warning" role="alert">
       缺少简介
      </div>
    [/#if]
  </div>

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">教学大纲</h3>
    </div>
      [#if syllabusDocs?size>0]
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead style="text-align:center">
         <th>作者</th>
         <th>附件</th>
         <th>更新学期</th>
         <th>更新日期</th>
      </thead>
      <tbody >
      [#list syllabusDocs as doc]
      <tr style="text-align:center">
        <td>${doc.writer.name}</td>
        <td>[@b.a href="!attachment?doc.id="+doc.id target="_blank"]<span style="color:#6c757d">${doc.docSize/1024.0}K</span>下载&nbsp;[/@]</td>
        <td>${doc.semester.schoolYear} 学年 ${doc.semester.name} 学期</td>
        <td>${doc.updatedAt?string("yyyy-MM-dd HH:mm")}</td>
      </tr>
      [/#list]
    </table>
    [#else]
      <div class="alert alert-default-warning" role="alert">
       缺少教学大纲
      </div>
    [/#if]
  </div>

    [#if clazzInfos?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      [#assign semesters=[]/][#assign totalClazzCount=0/]
      [#list clazzInfos as clazzInfo]
        [#if !semesters?seq_contains(clazzInfo.semester)][#assign semesters=semesters+[clazzInfo.semester]/] [/#if]
        [#assign totalClazzCount=totalClazzCount + clazzInfo.clazzCount/]
      [/#list]
      <h3 class="card-title">近五年开课信息</h3>
      <span class="badge badge-primary">${semesters?size}个学期，共计${totalClazzCount}个班次</span>
    </div>
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead>
         <th>学年学期</th>
         <th>开课院系</th>
         <th>授课教师</th>
         <th>开班次数</th>
      </thead>
      <tbody >
      [#list clazzInfos as clazzInfo]
      <tr>
        <td>${clazzInfo.semester.schoolYear} 学年 ${clazzInfo.semester.name} 学期</td>
        <td>${clazzInfo.department.name}</td>
        <td>[#list clazzInfo.teachers as t]${t.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>${clazzInfo.clazzCount}</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]

[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]</div>[/#if]
[@b.foot/]
