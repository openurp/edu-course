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
  </style>
  <h5>${course.code} ${course.name}</h5>
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    <table class="infoTable">
      <tr>
        <td class="title" width="10%">代码:</td>
        <td class="content">${course.code}</td>
        <td class="title" width="10%">名称:</td>
        <td class="content">${course.name}</td>
        <td class="title" width="10%">培养层次:</td>
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
        <td class="title">学分学时:</td>
        <td class="content">${course.defaultCredits!}学分  ${syllabus.creditHours}学时</td>
      </tr>
      <tr>
        <td class="title">院系:</td>
        <td class="content">${(syllabus.department.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(syllabus.examMode.name)!}</td>
        <td class="title">成绩记录方式:</td>
        <td class="content">${(syllabus.gradingMode.name)!}</td>
      </tr>
      <tr>
        <td class="title">课程性质:</td>
        <td class="content">${(syllabus.nature.name)!}</td>
        <td class="title">课程属性:</td>
        <td class="content">${(syllabus.rank.name)!}</td>
        <td class="title">课程模块:</td>
        <td class="content">${(syllabus.module.name)!}</td>
      </tr>
    </table>
  </div>

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <p class="card-title">课程介绍和资源</p>
      [@b.card_tools]
         [@b.a href="!syllabus?id="+syllabus.id target="_blank"]<i class="fa-solid fa-paperclip"></i>查看大纲全文[/@]&nbsp;
      [/@]
    </div>
    <table class="infoTable">
      <tr>
        <td class="title" width="10%">课程简介:</td>
        <td colspan="3">
          <p style="white-space: preserve;margin: 0px;">${syllabus.description!}</p>
        </td>
      </tr>
      <tr>
        <td class="title">先修课程:</td>
        <td class="content" colspan="3">${syllabus.prerequisites!}</td>
      </tr>
      <tr>
        <td class="title">并修课程:</td>
        <td class="content" colspan="3">${syllabus.corequisites!}</td>
      </tr>
      <tr>
        <td class="title">后续课程:</td>
        <td class="content" colspan="3">
          <div style="white-space: break-spaces;">${syllabus.subsequents!}</div>
        </td>
      </tr>
      <tr>
        <td class="title">教材:</td>
        <td class="content" colspan="3">
        [#list syllabus.textbooks as textbook]
          ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${textbook.publishedOn?string("yyyy-MM")} [#if syllabus.locale=="zh_CN"]版次:[#else]Edition:[/#if]${(textbook.edition)!}[#sep]<br/>
        [/#list]
        </td>
      </tr>
      <tr>
        <td class="title">参考书目:</td>
        <td class="content" colspan="3"><p style="white-space: preserve;margin: 0px;">${syllabus.bibliography!}</p></td>
      </tr>
      <tr>
        <td class="title">其他教学资源:</td>
        <td class="content" colspan="3"><p style="white-space: preserve;margin: 0px;">${syllabus.materials!}</p></td>
      </tr>
      [#if syllabus.website??]
      <tr>
        <td class="title">课程网站地址:</td>
        <td class="content" colspan="3"><a href="${syllabus.website}" target="_blank">${syllabus.website}</a></td>
      </tr>
      [/#if]
    </table>
  </div>

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <p class="card-title">${semester.schoolYear}学年${semester.name}学期开课信息</p>
    </div>
      <table class="table table-hover table-sm table-striped">
       <thead style="text-align:center">
         <th style="width:10%">课程序号</th>
         <th>教学班</th>
         <th style="width:15%">课程类别</th>
         <th style="width:20%">授课教师</th>
         <th style="width:10%">授课计划</th>
      </thead>
      <tbody>
      [#list plans?sort_by(["clazz","crn"]) as plan]
      <tr style="text-align:center">
        <td>${plan.clazz.crn}</td>
        <td>${plan.clazz.clazzName}</td>
        <td>${plan.clazz.courseType.name}</td>
        <td>[#list plan.clazz.teachers as t]${t.name}[#if t_has_next]&nbsp;[/#if][/#list]</td>
        <td>[@b.a href="!plan?id="+plan.id target="_blank"]<i class="fa-solid fa-paperclip"></i>查看授课计划[/@]</td>
      </tr>
      [/#list]
    </table>
  </div>

</div>
[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]
  <script>
     document.title="${course.code} ${course.name}";
  </script>
[/#if]
[@b.foot/]
