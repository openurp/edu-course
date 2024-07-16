[#ftl/]
[@b.head/]
  <style>
    .card-header{
      padding:.5rem 1.25rem;
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
    <div class="card-header">
      <h4 class="card-title">教学大纲</h4>
      [#if task??]
        [@b.a class="btn btn-primary btn-sm" href="!editNew?course.id=" + course.id + "&semester.id=" + semester.id + "&locale=en_US"  target="_blank" style="float:right;margin-left:20px"]新增英文大纲[/@]
        [@b.a class="btn btn-primary btn-sm" href="!editNew?course.id=" + course.id + "&semester.id=" + semester.id target="_blank" style="float:right"]新增中文大纲[/@] &nbsp;
      [/#if]
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
             <a href="#" onclick="return copySetting('${syllabus.id}')">复制到..</a>
             [#if task?? && editables?seq_contains(syllabus.status)]
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
