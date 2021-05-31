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
                <tr>
                 <td width="80%">[@b.a href="!info?id="+course.id target="course_list"]${course.name}[/@]</td>
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
