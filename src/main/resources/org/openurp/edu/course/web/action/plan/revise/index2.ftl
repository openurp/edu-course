[#ftl]
[@b.head/]
[#include "info_macros.ftl"/]
<style>
  .card-header{
    padding:0.5rem 1.25rem;
  }
</style>
[@info_header title="教学计划维护"/]
<div class="container-fluid">
  <div class="row">
     <div class="col-3" id="accordion">

       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_2">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_2" style="padding: 0;">
                我的教学任务
              </button>
            </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_2" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list clazzes as clazz]
                  [#assign error_msg=""/]
                <tr>
                 <td>
                   <span style="color:#6c757d;font-size:0.8em">${clazz.course.code}</span>
                   [@b.a href="!clazz?clazz.id="+clazz.id target="course_list"]<span>${clazz.crn} ${clazz.course.name}</span>[/@]
                 </td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>

     </div><!--end col-3-->
     [#if clazzes?size>0]
     [@b.div class="col-9" id="course_list" href="!clazz?clazz.id="+clazzes?first.id/]
     [#else]
     <div>你还没有带课</div>
     [/#if]
  </div><!--end row-->
</div><!--end container-->
[@b.foot/]
