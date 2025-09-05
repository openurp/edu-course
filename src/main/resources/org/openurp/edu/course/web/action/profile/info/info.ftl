[#ftl]
[@b.head/]
[@b.toolbar title="课程信息"]
  bar.addClose();
[/@]
<div class="container">
  <style>
    .card-header{
      padding:.5rem 1.25rem;
    }
    table td.title{
      padding: 0.2rem 0rem;
      text-align: right;
      color: #6c757d !important;
    }
  </style>
  <h5><i class="fa-solid fa-book-open"></i>&nbsp;${course.code} ${course.name}</h5>
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    <table class="table table-sm" style="table-layout:fixed">
      <colgroup>
        <col width="13%"/>
        <col width="20%"/>
        <col width="13%"/>
        <col width="22%"/>
        <col width="12%"/>
        <col width="20%"/>
      </colgroup>
      <tr>
        <td class="title">代码:</td>
        <td class="content">${course.code}</td>
        <td class="title">名称:</td>
        <td class="content">${course.name}</td>
        <td class="title">培养层次:</td>
        <td class="content">
          [#list course.levels as level]
            ${level.level.name}
            [#if level_has_next],[/#if]
          [/#list]
        </td>
      </tr>
      <tr>
        <td class="title">英文名:</td>
        <td class="content" colspan="3">${course.enName!}</td>
        <td class="title">学分:</td>
        <td class="content">${course.defaultCredits!}</td>
      </tr>
      <tr>
        <td class="title">学时:</td>
        <td class="content">${course.creditHours!}</td>
        <td class="title">周课时:</td>
        <td class="content">${course.weekHours!}</td>
        <td class="title">周数:</td>
        <td class="content">${course.weeks!}</td>
      </tr>
      <tr>
        <td class="title">院系:</td>
        <td class="content">${(course.department.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(course.examMode.name)!}</td>
        <td class="title">成绩记录方式:</td>
        <td class="content">${(course.gradingMode.name)!}</td>
      </tr>
      <tr>
        <td class="title">课程性质:</td>
        <td class="content">${(course.nature.name)!}</td>
        <td class="title">课程类别:</td>
        <td class="content">${(course.courseType.name)!}</td>
        <td class="title">课程模块:</td>
        <td class="content">${(course.module.name)!}</td>
      </tr>
    </table>
    </div>

    [#if profile??]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <p class="card-title">课程介绍</p>
    </div>
    <table class="table table-sm" style="table-layout:fixed">
      <tr>
        <td class="title" width="13%">课程简介:</td>
        <td class="content" colspan="3">
          <div style="white-space:break-spaces; word-break:break-all;">${profile.description}</div>
        </td>
      </tr>
      [#if profile.enDescription??]
      <tr>
        <td class="title">英文简介:</td>
        <td class="content" colspan="3">
          <div style="white-space:break-spaces; word-break:break-all;">${profile.enDescription}</div>
        </td>
      </tr>
      [/#if]
      [#if profile.prerequisites??]
      <tr>
        <td class="title">先修课程:</td>
        <td class="content" colspan="3">${profile.prerequisites}</td>
      </tr>
      [/#if]
      [#if (profile.majors)??]
      <tr>
        <td class="title">适用专业:</td>
        <td class="content" colspan="3">${profile.majors!}</td>
      </tr>
      [/#if]
      [#if profile.textbooks?? && profile.textbooks!='--']
      <tr>
        <td class="title">默认教材:</td>
        <td class="content" colspan="3">
          <div style="white-space: break-spaces;">${profile.textbooks}</div>
        </td>
      </tr>
      [#else]
      <tr>
        <td class="title">默认教材:</td>
        <td class="content" colspan="3">
          <div style="white-space: break-spaces;">[#t/]
            <ul style="margin: 0px;padding-left: 0px;list-style: none;">[#list profile.books as book]<li>${book.name} ${book.author!} ${(book.press.name)!} ${book.isbn!} ${book.edition!}</li>[/#list]</ul>[#t/]
          </div>[#t/]
        </td>
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
        <td class="content" colspan="3"><a href="${profile.website}" target="_blank">${profile.website}</a></td>
      </tr>
      [/#if]
    </table>
  </div>
    [/#if]

    [#if syllabusDocs?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <p class="card-title">教学大纲</p>
    </div>
      <table class="table table-hover table-sm table-striped">
       <thead style="text-align:center">
         <th>编写人</th>
         <th>更新学期</th>
         <th>更新日期</th>
         <th>附件</th>
      </thead>
      <tbody >
      [#list syllabusDocs as doc]
      <tr style="text-align:center">
        <td>${doc.writer.name}</td>
        <td>${doc.semester.schoolYear} 学年 ${doc.semester.name} 学期</td>
        <td class="text-muted">${doc.updatedAt?string("yyyy-MM-dd HH:mm")}</td>
        <td>[@b.a href="!attachment?doc.id="+doc.id target="_blank"]<span class="text-muted">${doc.docSize/1024.0}K</span><i class="fa-solid fa-paperclip"></i>下载&nbsp;[/@]</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]

    [#if clazzInfos?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      [#assign semesters=[]/][#assign totalClazzCount=0/]
      [#list clazzInfos as clazzInfo]
        [#if !semesters?seq_contains(clazzInfo.semester)][#assign semesters=semesters+[clazzInfo.semester]/] [/#if]
        [#assign totalClazzCount=totalClazzCount + clazzInfo.clazzCount/]
      [/#list]
      <p class="card-title">近十年开课信息</p>
      <span class="badge badge-primary">${semesters?size}个学期，共计${totalClazzCount}个班次</span>
    </div>
      <table class="table table-hover table-sm table-striped">
       <thead style="text-align:center">
         <th style="width:15%">学年学期</th>
         <th style="width:15%">开课院系</th>
         <th>授课教师</th>
         <th style="width:10%">开班次数</th>
      </thead>
      <tbody>
      [#list clazzInfos as clazzInfo]
      <tr style="text-align:center">
        <td>${clazzInfo.semester.schoolYear}学年${clazzInfo.semester.name}学期</td>
        <td>${clazzInfo.department.name}</td>
        <td>[#list clazzInfo.teachers as t]${t.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>${clazzInfo.clazzCount}</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]

[#if planCourseInfos?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <p class="card-title">计划开课信息</p>
    </div>
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead>
         <th>年级</th>
         <th>学历层次</th>
         <th style="width:55%">专业</th>
         <th>课程类型</th>
         <th>开课学期</th>
         <th>门次数</th>
      </thead>
      <tbody >
      [#list planCourseInfos as planCourseInfo]
      <tr>
        <td>${planCourseInfo.grade}</td>
        <td>[#list planCourseInfo.levels as t]${t.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>[#list planCourseInfo.majors as t]${t.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>${planCourseInfo.courseType.name}</td>
        <td>${planCourseInfo.terms}</td>
        <td>${planCourseInfo.count}</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]
</div>
[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]
  <script>
     document.title="${course.code} ${course.name}";
  </script>
[/#if]
[@b.foot/]
