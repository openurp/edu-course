[#ftl/]
[@b.head/]
<div class="container">
  [@b.messages slash="3"/]
  <div class="card card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">${course.code} ${course.name}</h4>
    </div>
    <table class="infoTable">
      <tr>
        <td class="title"  width="10%">代码:</td>
        <td class="content">${course.code}</td>
        <td class="title"  width="10%">名称:</td>
        <td class="content">${course.name}</td>
        <td class="title">学分、学时:</td>
        <td class="content">${course.defaultCredits!}、${course.creditHours!}</td>
      </tr>
      <tr>
        <td class="title">面向层次:</td>
        <td class="content">[#list course.levels as l]${l.level.name}[#sep],[/#list]</td>
        <td class="title"  width="10%">英文名:</td>
        <td class="content" colspan="3">${course.enName!}</td>
      </tr>
      <tr>
        <td class="title">开课院系:</td>
        <td class="content">${(course.department.name)!}</td>
        <td class="title">课程模块:</td>
        <td class="content">${(course.module.name)!}</td>
        <td class="title">课程类别:</td>
        <td class="content">${(course.courseType.name)!}</td>
      </tr>
       <tr>
        <td class="title">课程性质:</td>
        <td class="content">${(course.rank.name)!}</td>
        <td class="title">课程性质:</td>
        <td class="content">${(course.nature.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(course.examMode.name)!}</td>
      </tr>
    </table>
  </div>

  <div class="card card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">课程简介、大纲、教材信息</h3>
      <div class="card-tools">
       [#if editable]
         [#if !profile?? || profile?? && profile.semester!=semester]
           [@b.a class="btn btn-outline-primary btn-sm" href="!editProfile?renew=1&courseId=" +course.id+"&semester.id="+semester.id]新增[/@]
         [#else]
            [@b.a class="btn btn-outline-primary btn-sm" href="!editProfile?courseId=" +course.id+"&semester.id="+semester.id]修改[/@]
         [/#if]
       [/#if]
       [#if profile??]<span class="text-muted">${profile.beginOn}~[#if profile.endOn??]${profile.endOn}[#else]至今[/#if]有效</span>[/#if]
     </div>
    [#if task??]
      [#if (task.teachers?size>1) && (!task.director?? || task.director?? && task.director.code == me)]
        <div class="dropdown" style="float:right;">
        <button class="btn btn-outline-primary btn-sm dropdown-toggle" type="button" data-toggle="dropdown">
        更改课程负责人: ${(task.director.name)!'--'}
        <span class="caret"></span>
        </button>
        <ul class="dropdown-menu" style="padding-left: 20px;">
         [#list task.teachers?sort_by('name') as t]
         <li>[@b.a href="!changeDirector?task.id="+task.id+"&director.id="+t.id
              onclick="if(confirm('确认更换课程负责人为：${t.name}?')){ return bg.Go(this)} else return false;"]${t.name}[/@]
         </li>
         [/#list]
        </ul>
        </div>
      [#else]
       <div style="float:right;"><button class="btn btn-outline-primary btn-sm">负责人:${(task.director.name)!'--'}</button></div>
      [/#if]
    [/#if]
    </div>
    [#if profile??]
      <table class="infoTable">
      <tr>
        <td class="title" width="10%">课程简介:</td>
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
      <tr>
        <td class="title">教材选用类型:</td>
        <td class="content" colspan="3">${profile.bookAdoption}</td>
      </tr>
      [#if profile.books?? && profile.books?size>0]
      <tr>
        <td class="title">使用教材:</td>
        <td class="content" colspan="3">
          <div style="white-space: pre;">[#t/]
          [#list profile.books as book][#lt/]
          ${book}[#lt/]
          [/#list][#lt/]
          </div>[#t/]
        </td>
      </tr>
      [/#if]
      [#if profile.textbooks??]
      <tr>
        <td class="title">默认教材:</td>
        <td class="content" colspan="3">${profile.textbooks}</td>
      </tr>
      [/#if]
      [#if profile.bibliography??]
      <tr>
        <td class="title">参考书目:</td>
        <td class="content" colspan="3">${profile.bibliography}</td>
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
    [#else]
      <div class="alert alert-default-warning" role="alert">
       缺少简介
      </div>
    [/#if]

    [#if activeDocs?size>0 || historyDocs?size>0]
    <table class="table table-hover table-sm table-striped" style="font-size:13px">
     <thead style="text-align:center">
       <th>作者</th>
       <th>附件</th>
       <th>更新学期</th>
       <th>更新日期</th>
    </thead>
    <tbody >
      [#list activeDocs as doc]
      <tr style="text-align:center">
        <td>${doc.writer.name}</td>
        <td>[@b.a href="!attachment?doc.id="+doc.id target="_blank"]<span style="color:#6c757d">${doc.docSize/1024.0}K</span>下载&nbsp;[/@]</td>
        <td>${doc.semester.schoolYear} 学年 ${doc.semester.name} 学期</td>
        <td>${doc.updatedAt?string("yyyy-MM-dd HH:mm")}</td>
      </tr>
      [/#list]
      [#list historyDocs as doc]
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
  <div class="card card-primary card-outline">
    <div class="card-header">
      [#assign semesters=[]/][#assign totalClazzCount=0/]
      [#list clazzInfos as clazzInfo]
        [#if !semesters?seq_contains(clazzInfo.semester)][#assign semesters=semesters+[clazzInfo.semester]/] [/#if]
        [#assign totalClazzCount=totalClazzCount + clazzInfo.clazzCount/]
      [/#list]
      <h3 class="card-title">历史开课信息</h3>
      <span class="badge badge-primary">${semesters?size}个学期，共计${totalClazzCount}个班次</span>
    </div>
    <div class="card-body" style="padding-top:0px;">
      <table class="table table-hover table-sm table-striped" style="font-size:13px">
       <thead>
         <tr>
           <th>学年学期</th>
           <th>开课院系</th>
           <th>授课教师</th>
           <th>开班次数</th>
         </tr>
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
  </div>
  [/#if]

</div>

[@b.foot/]
