[#ftl/]
[@b.head/]
  <style>
    .card-header{
      padding:.5rem 1.25rem;
    }
    .panel-header {
      border-bottom: 1px solid #048BB3;
      margin-bottom: 0px;
      margin-top: 10px;
      font-size:0.8rem;
      padding: 0px 0px 1px 0px;
    }
  </style>
<div class="container">
  [@b.messages slash="3"/]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">${course.code} ${course.name}</h4>
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
    <nav class="navbar navbar-expand">
      <h4 class="card-title" style="padding: .5rem 1.25rem;">教学大纲</h4>
      [#if task??]
      [#if others?size>0]
      <ul class="nav navbar-nav ml-auto">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">[#list 1..40 as i]&nbsp;[/#list]从近三年大纲中复制...</a>
          <div class="dropdown-menu">
            [#list others as g]
              [@b.a class="nav-link" href="!copy?course.id=${course.id}&syllabus.id=${g.id}&semester.id=${semester.id}" target="course_list"]${g.semester.schoolYear} ${g.semester.name} ${g.course.code} ${g.course.name} ${locales.get(g.docLocale)}[/@]
            [/#list]
          </div>
        </li>
        <li class="nav-item">
          [@b.a class="btn btn-outline-primary btn-sm" href="!editNew?course.id=" + course.id + "&semester.id=" + semester.id target="_blank" style="float:right"]新增中文大纲[/@] &nbsp;
        </li>
        <li class="nav-item">
          [@b.a class="btn btn-outline-primary btn-sm" href="!editNew?course.id=" + course.id + "&semester.id=" + semester.id + "&locale=en_US"  target="_blank" style="float:right;margin-left:20px"]新增英文大纲[/@]
        </li>
      </ul>
      [/#if]
      [/#if]
    </nav>
    <div class="card-body" style="padding-top: 0px;">
     <table class="table table-hover table-sm table-striped">
       [#if syllabuses?size==0]
       <tr><td style="text-align:center;">本学期无大纲</td></tr>
       [/#if]
         [#list syllabuses as syllabus]
       <tr>
         <td style="width: 24%;">${syllabus.semester.schoolYear}学年${syllabus.semester.name}学期</td>
         <td style="width: 7%;">${locales.get(syllabus.docLocale)}</td>
         <td style="width: 10%;">${syllabus.writer.name}</td>
         <td style="width: 13%;">${syllabus.status}</td>
         <td style="width: 15%;">${syllabus.updatedAt?string('yyyy-MM-dd HH:mm')}</td>
         <td style="width: 16%;">
           <a href="#" onclick="return copySetting('${syllabus.id}')">复制到..</a>
           [#if task?? && editables?seq_contains(syllabus.status)]
           [@b.a href="!edit?id=${syllabus.id}" target="_blank"]修改[/@]
           [@b.a href="!remove?id=${syllabus.id}&semester.id="+semester.id onclick="if(confirm('确定删除该教学大纲吗吗?')){return bg.Go(this,null)}else{return false;}"]删除[/@]
           [/#if]
         </td>
         <td style="width: 15%;">[@b.a href="!info?id=${syllabus.id}" target="_blank"]查看[/@]&nbsp;[@b.a href="!pdf?id=${syllabus.id}" target="_blank"]下载PDF[/@]</td>
       </tr>
         [/#list]
     </table>
     [#if histories?size>0]
     <h6 class="panel-header"><span class="panel_title text-muted">其他学期大纲</span></h6>
     <table class="table table-hover table-sm table-striped">
         [#list histories as syllabus]
       <tr>
         <td style="width: 24%;">${syllabus.semester.schoolYear}学年${syllabus.semester.name}学期</td>
         <td style="width: 7%;">${locales.get(syllabus.docLocale)}</td>
         <td style="width: 10%;">${syllabus.writer.name}</td>
         <td style="width: 13%;">${syllabus.status}</td>
         <td style="width: 15%;">${syllabus.updatedAt?string('yyyy-MM-dd HH:mm')}</td>
         <td style="width: 16%;">
           <a href="#" onclick="return copySetting('${syllabus.id}')">复制到..</a>
         </td>
         <td style="width: 15%;">[@b.a href="!info?id=${syllabus.id}" target="_blank"]查看[/@]&nbsp;[@b.a href="!pdf?id=${syllabus.id}" target="_blank"]下载PDF[/@]</td>
       </tr>
         [/#list]
     </table>
     [/#if]
    </div>
  </div>

  <div class="modal fade" id="courseListDialog" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">选择复制到具体课程</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body" style="padding-top:0px;">
          <div id='courseListDiv' style="width:100%"></div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-dismiss="modal">放弃复制</button>
          <button class="btn btn-sm btn-outline-primary" onclick="return doCopy();">开始复制</button>
        </div>
      </div>
    </div>
  </div>
  <script>
    beangle.load(["jquery-colorbox"]);
    function copySetting(syllabusId){
      bg.Go('${b.url('!copySetting?semester.id='+Parameters['semester.id'])}'+"&syllabus.id="+syllabusId,"courseListDiv")
      jQuery("#courseListDialog").modal('show');
      return false;
    }
    function doCopy(){
      jQuery("#courseListDialog").modal('hide');
      //如果立马提交，半透明遮罩层没有去除
      setTimeout(function(){
        bg.form.submit(document.copyCourseForm);
      },500);
      return false;
    }
  </script>
</div>
[@b.foot/]
