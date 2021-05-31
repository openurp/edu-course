[#ftl]
[@b.head/]
[@b.toolbar title="课程信息"]
  bar.addClose();
[/@]
<div class="container">
  <h3>${course.code} ${course.name}</h3>
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    <table class="infoTable">
      <tr>
        <td class="title" width="20%">代码:</td>
        <td class="content">${course.code}</td>
        <td class="title" width="20%">名称:</td>
        <td class="content">${course.name}</td>
      </tr>
      <tr>
        <td class="title">英文名:</td>
        <td class="content">${course.enName!}</td>
        <td class="title">培养层次:</td>
        <td class="content">
          [#list course.levels as level]
            ${level.name}
            [#if level_has_next],[/#if]
          [/#list]
        </td>
      </tr>
      <tr>
        <td class="title">学分:</td>
        <td class="content">${course.credits!}</td>
        <td class="title">学时:</td>
        <td class="content">${course.creditHours!}</td>
      </tr>
      <tr>
        <td class="title">周课时:</td>
        <td class="content">${course.weekHours!}</td>
        <td class="title">周数:</td>
        <td class="content">${course.weeks!}</td>
      </tr>
      <tr>
        <td class="title">院系:</td>
        <td class="content">${(course.department.name)!}</td>
        <td class="title">建议课程类别:</td>
        <td class="content">${(course.courseType.name)!}</td>
      </tr>
      <tr>
        <td class="title">评教分类:</td>
        <td class="content">${(course.category.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(course.examMode.name)!}</td>
      </tr>
      [#if course.majors?size>0 || course.xmajors?size>0]
      <tr>
        <td class="title">适用专业:</td>
        <td class="content">[#list course.majors as m]${m.name}[#if m_has_next]&nbsp;[/#if][/#list]</td>
        <td class="title">不适用专业:</td>
        <td class="content">[#list course.xmajors as m]${m.name}[#if m_has_next]&nbsp;[/#if][/#list]</td>
      </tr>
      [/#if]
      [#if course.textbooks?size>0]
      <tr>
        <td class="title">默认教材:</td>
        <td class="content" colspan="3">
        [#list course.textbooks as b]${b.isbn} ${b.name} ${b.author} ${b.press.name} ${b.edition!}[#if b_has_next]<br>[/#if][/#list]
        </td>
      </tr>
      [/#if]
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
      <table class="table table-hover table-sm table-striped">
       <thead>
         <th>作者</th>
         <th>更新学期</th>
         <th>附件</th>
      </thead>
      <tbody >
      [#list syllabuses as syllabus]
      <tr>
        <td>${syllabus.author.name}</td>
        <td>${syllabus.semester.schoolYear} 学年 ${syllabus.semester.name} 学期</td>
        <td>[#list syllabus.attachments as a]大纲${a_index}[#if a_has_next]&nbsp;[/#if][/#list]</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]

    [#if clazzInfos?size>0]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">开课信息</h3><span class="badge badge-primary">近五年</span>
    </div>
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead>
         <th>学年学期</th>
         <th>开课院系</th>
         <th>授课教师</th>
         <th>开班数</th>
      </thead>
      <tbody >
      [#list clazzInfos as clazzInfo]
      <tr>
        <td>${clazzInfo.semester.schoolYear} 学年 ${clazzInfo.semester.name} 学期</td>
        <td>${clazzInfo.department.name}</td>
        <td>[#list clazzInfo.teachers as t]${t.user.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>${clazzInfo.clazzCount}</td>
      </tr>
      [/#list]
    </table>
  </div>
    [/#if]
</div>
[@b.foot/]
