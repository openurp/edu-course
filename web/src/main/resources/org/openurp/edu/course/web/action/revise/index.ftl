[#ftl]
[@b.head/]
[#include "info_macros.ftl"/]
[@info_header title="课程资料"/]
<div class="container-fluid">
  <div class="row">
     <div class="col-3" id="accordion">

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
               [#list courses as course]
                  [#assign error_msg=""/]
                  [#if !hasProfileCourses?seq_contains(course.id)] [#assign error_msg="缺少简介"/][/#if]
                  [#if !hasSyllabusCourses?seq_contains(course.id)] [#assign error_msg= error_msg + " 缺少大纲"/][/#if]
                <tr title="${error_msg}">
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!info?id="+course.id target="course_list"]<span>${course.name}</span>[/@]
                 </td>
                 <td>
                  [#if hasProfileCourses?seq_contains(course.id)]<i class="fas fa-list-ul"></i>[/#if]
                  [#if hasSyllabusCourses?seq_contains(course.id)]<i class="fas fa-paperclip"></i>
                  [#else]<span style="color:red;font-size:0.6em"><i class="fas fa-circle"></i></span>[/#if]
                 </td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>

     </div><!--end col-3-->
     [#if courses?size>0]
     [@b.div class="col-9" id="course_list" href="!info?id="+courses?first.id/]
     [#else]
     <div>你还没有代课</div>
     [/#if]
  </div><!--end row-->
</div><!--end container-->
[@b.foot/]
