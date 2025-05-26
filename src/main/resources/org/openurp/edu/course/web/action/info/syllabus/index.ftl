[#ftl]
[@b.head/]
<style>
  .header {
    width:100%;
    border-bottom: 1px solid;
    color:rgb(192,0,0);
    font-family: 楷体;
  }
</style>
<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="brand">
      <img src="${b.static_url('local','/images/logo.png')}" width="50px"/>
       [@b.a href="!index"]${project.school.name}·课程教学大纲和授课计划[/@]
    </div>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <a href="#"class="nav-link" onclick="return toggleEnCourseName(this)">显示课程英文名</a>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
          ${semester.schoolYear}学年${semester.name}学期
        </a>
        <div class="dropdown-menu">
          [#list semesters as s]
          [@b.a class="dropdown-item" href="!index?semester.id=${s.id}"]${s.schoolYear}学年${s.name}学期[/@]
          [/#list]
        </div>
      </li>
    </ul>
  </nav>
</header>

<div class="container-fluid">
  <div class="row">
     <div class="col-2" id="accordion">

       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_1">
           <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                开课院系统计
              </button>
            [#assign total=0]
            [#list departStat as s]
            [#assign total=total+s[2]]
            [/#list]
            <span style="float: right;font-size: 0.75rem;" class="badge badge-primary">${total}</span>
           </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list departStat as stat]
                <tr>
                 <td width="80%">[@b.a href="!search?semester.id=" + semester.id + "&syllabus.department.id="+stat[0] target="syllabus_list"]${stat[1]}[/@]</td>
                 <td width="20%">${stat[2]}</td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>

     [#--
       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_1">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                课程标签
              </button>
            </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;max-height:400px;overflow:scroll;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list tagStat as stat]
                <tr>
                 <td width="80%">[@b.a href="!search?tag.id="+stat[0] target="syllabus_list"]${stat[1]}[/@]</td>
                 <td width="20%">${stat[2]}</td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>
       --]

     </div><!--end col-3-->
     [@b.div class="col-10" id="syllabus_list" href="!search?semester.id="+semester.id /]
  </div><!--end row-->
</div><!--end container-->
<script>
  function toggleEnCourseName(e){
    if(e.innerHTML=="隐藏课程英文名"){
      jQuery(".en_course_name").hide()
      e.innerHTML="显示课程英文名";
    }else{
      jQuery(".en_course_name").show()
      e.innerHTML="隐藏课程英文名";
    }
    return false;
  }
</script>
[@b.foot/]
