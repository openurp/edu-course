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
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_2" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list activeCourses as course]
                  [#assign error_msg=""/]
                  [#if !hasProfileCourses?seq_contains(course.id)] [#assign error_msg="缺少简介"/][/#if]
                  [#if !hasSyllabusCourses?seq_contains(course.id)] [#assign error_msg= error_msg + " 缺少大纲"/][/#if]
                <tr title="${error_msg}">
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!info?id="+course.id target="course_list"]<span>${course.name}</span>[/@]
                  [#if error_msg?length>0]<span style="color:orange;font-size:0.8em"><i class="fas fa-exclamation"></i></span>[/#if]
                 </td>
                </tr>
                [/#list]
                [#if hisCourses?size>0]<tr><td style="color:#6c757d;text-align:center">历史课程</td></tr>[/#if]
               [#list hisCourses as course]
                  [#assign error_msg=""/]
                  [#if !hasProfileCourses?seq_contains(course.id)] [#assign error_msg="缺少简介"/][/#if]
                  [#if !hasSyllabusCourses?seq_contains(course.id)] [#assign error_msg= error_msg + " 缺少大纲"/][/#if]
                <tr title="${error_msg}">
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${course.code}</span>
                   [@b.a href="!info?id="+course.id target="course_list"]<span>${course.name}</span>[/@]
                  [#if error_msg?length>0]<span style="color:orange;font-size:0.8em"><i class="fas fa-exclamation"></i></span>[/#if]
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
