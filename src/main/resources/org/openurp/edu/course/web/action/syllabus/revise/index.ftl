[#ftl]
[@b.head/]
<style>
  .card-header{
    padding:0.5rem 1.25rem;
  }
</style>
[@b.toolbar title="每学期课程大纲修订"/]
[@base.semester_bar value=semester/]

<div class="container-fluid">
  <div class="row">
     <div class="col-3" id="accordion">

       [#if taskCourses?size>0]
       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_1">
           <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_1" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                我的修订任务
              </button>
              [#if en_template_url??]
              <a class="btn btn-link" style="padding: 0px 0px 0px 10px;float:right" title="课程大纲英文模板" href="${en_template_url}" target="_blank">
                <i class="fas fa-paperclip"></i>英文
              </a>
              [/#if]
              [#if zh_template_url??]
              <a class="btn btn-link" style="padding: 0;float:right" title="课程大纲中文模板" href="${zh_template_url}" target="_blank">
                <i class="fas fa-paperclip"></i>中文
              </a>
              [/#if]
           </h5>
         </div>
         <div id="stat_body_1" class="collapse show" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list taskCourses as course]
                <tr>
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!course?course.id="+course.id+"&semester.id="+semester.id target="course_list"]<span>${course.name}</span>[/@]
                 </td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>
       [/#if]

       [#if clazzCourses?size>0]
       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_2">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_2" style="padding: 0;">
                我的课程
              </button>
            </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_2" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list clazzCourses as course]
                <tr>
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!course?course.id="+course.id+"&semester.id="+semester.id target="course_list"]<span>${course.name}</span>[/@]
                 </td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>
       [/#if]

       [#if hisCourses?size>0]
       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_3">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_3" aria-expanded="true" aria-controls="stat_body_3" style="padding: 0;">
                历史学期课程
              </button>
            </h5>
         </div>
         <div id="stat_body_3" class="collapse show" aria-labelledby="stat_header_3" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list hisCourses as course]
                <tr>
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!course?course.id="+course.id+"&semester.id="+semester.id target="course_list"]<span>${course.name}</span>[/@]
                 </td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>
       [/#if]

     </div><!--end col-3-->

     [#if courses?size>0]
     [@b.div class="col-9" id="course_list" href="!course?course.id="+courses?first.id+"&semester.id="+semester.id/]
     [#else]
     <div>你还没有带课</div>
     [/#if]
  </div><!--end row-->
</div><!--end container-->
[@b.foot/]
