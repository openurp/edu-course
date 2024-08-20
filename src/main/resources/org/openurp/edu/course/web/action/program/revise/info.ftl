[@b.head /]
  <link rel="stylesheet" type="text/css" href="${b.base}/static/edu/course/css/outline.css" />
  <script type="module" charset="utf-8" src="${b.base}/static/edu/course/js/outline.js?v=2"></script>
  <style>
    p{
      margin-bottom:0px;
    }
  </style>
<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="brand">
      <img src="${b.static_url('local','/images/logo.png')}" width="50px"/>
      [@b.a href="!info?clazz.id="+clazz.id+"&program.id="+program.id ]${clazz.semester.schoolYear}学年度 ${clazz.semester.name}学期 ${clazz.crn} ${clazz.course.name} ${clazz.course.code} 授课教案[/@]
    </div>

    <ul class="navbar-nav ml-auto">
     <li>
     ${schedule!}
     </li>
    </ul>
  </nav>
</header>

<div id="page-body">
  <aside id="page-left-aside">
    <div id="catalogs" class="page-body-module">
      <div class="page-body-module-title">章节</div>
      <div class="page-body-module-content"></div>
    </div>
  </aside>
  <main>
    <article id="article" class="page-body-module" style="padding:10px 20px;">
      <div class="page-body-module-content">
        [#assign designs={}/]
        [#list program.designs as design]
          [#assign designs=designs+{design.idx?string:design}/]
        [/#list]
        [#list plan.lessons?sort_by("idx") as lesson]
          <div id="lesson-block${lesson_index+1}" class="ajax_container">
          [#if designs[(lesson_index+1)?string]??]
            [#assign design = designs[(lesson_index+1)?string]/]
            [#include "designInfo.ftl"/]
          [#else]
            <div class="card">
              <div class="card-header">
                  <h1 style="display:inline;">
                    <a class="q-anchor q-heading-anchor" name="lesson${lesson_index+1}"></a>第${(lesson_index+1)?string?left_pad(2,"0")}次课
                    [#if schedules?? &&schedules[lesson_index]??]<small>(${schedules[lesson_index].date})</small>[/#if]
                  </h1>
                  尚无
              </div>
            </div>
          [/#if]
          </div>
        [/#list]
      </div>
    </article>
  </main>
</div>
[@b.foot/]
