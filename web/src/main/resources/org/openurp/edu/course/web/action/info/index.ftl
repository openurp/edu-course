[#ftl]
[@b.head/]
[#include "info_macros.ftl"/]
[@info_header title="基本信息"/]
<div class="container-fluid">
  <div class="row">
     <div class="col-3" id="accordion">

       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_2">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_2" style="padding: 0;">
                所属院系统计
              </button>
            </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_2" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list departStat as stat]
                <tr>
                 <td width="80%">[@b.a href="!search?course.department.id="+stat[0] target="course_list"]${stat[1]}[/@]</td>
                 <td width="20%">${stat[2]}</td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>

       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_1">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_1" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                课程性质统计
              </button>
            </h5>
         </div>
         <div id="stat_body_1" class="collapse" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
              <tbody>
              [#list natureStat as stat]
               <tr>
                <td>[@b.a href="!search?course.nature.id="+stat[0] target="course_list"]${stat[1]}[/@]</td>
                <td>${stat[2]}</td>
               </tr>
               [/#list]
              </tbody>
            </table>
           </div>
         </div>
       </div>

       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_3">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_3" aria-expanded="true" aria-controls="stat_body_3" style="padding: 0;">
                课程类别统计
              </button>
            </h5>
         </div>
         <div id="stat_body_3" class="collapse" aria-labelledby="stat_header_3" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
              <tbody>
              [#list typeStat as stat]
               <tr>
                <td>[@b.a href="!search?course.courseType.id="+stat[0] target="course_list"]${stat[1]}[/@]</td>
                <td>${stat[2]}</td>
               </tr>
               [/#list]
              </tbody>
            </table>
           </div>
         </div>
       </div>

     </div><!--end col-3-->
     [@b.div class="col-9" id="course_list" href="!search"/]
  </div><!--end row-->
</div><!--end container-->
[@b.foot/]
