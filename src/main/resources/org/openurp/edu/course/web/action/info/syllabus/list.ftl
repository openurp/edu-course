[#ftl]

  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">课程大纲信息[#if department??]<span class="text-muted">(${department.name})</span>[/#if]
        <span class="badge badge-primary">${syllabuses.totalItems}</span>
      </h3>
      [@b.form name="searchForm" action="!search" class="form-inline ml-3 float-right" ]
        <div class="input-group input-group-sm">
          <input class="form-control form-control-navbar" type="search" name="q" value="${Parameters['q']!}" aria-label="Search" placeholder="输入搜索关键词" autofocus="autofocus">
          [#list Parameters?keys as k]
           [#if k != 'q']
          <input type="hidden" name="${k}" value="${Parameters[k]?html}"/>
          [/#if]
          [/#list]
          <div class="input-group-append">
            <button class="input-group-text" type="submit" onclick="bg.form.submit(document.searchForm);return false;">
              <i class="fas fa-search"></i>
            </button>
          </div>
        </div>
        <nav class="navbar navbar-expand-lg navbar-light bg-white" style="padding: 0;">
          <ul class="navbar-nav ml-auto">
            [#assign examModeId=Parameters['syllabus.examMode.id']!""/]
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
                [#if examModeId == '']考核方式
                [#else]
                  [#list examModes as examMode]
                    [#if examModeId==examMode.id?string]${examMode.name}[#break/][/#if]
                  [/#list]
                [/#if]
              </a>
              <div class="dropdown-menu">
                [#list examModes as examMode]
                <a class="dropdown-item" href="#" onclick="enableFilter('syllabus.examMode.id','${examMode.id}');return false;">${examMode.name}</a>
                [/#list]
                <a class="dropdown-item" href="#" onclick="resetFilter('syllabus.examMode.id');return false;">全部</a>
              </div>
            </li>
            [#assign rankId=Parameters['syllabus.rank.id']!""/]
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
                [#if rankId == '']必修/选修
                [#else]
                  [#list ranks as rank]
                    [#if rankId==rank.id?string]${rank.name}[#break/][/#if]
                  [/#list]
                [/#if]
              </a>
              <div class="dropdown-menu">
                [#list ranks as rank]
                <a class="dropdown-item" href="#" onclick="enableFilter('syllabus.rank.id','${rank.id}');return false;">${rank.name}</a>
                [/#list]
                <a class="dropdown-item" href="#" onclick="resetFilter('syllabus.rank.id');return false;">全部</a>
              </div>
            </li>
            [#assign moduleId=Parameters['syllabus.module.id']!""/]
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
                [#if moduleId == '']课程模块
                [#else]
                  [#list modules as module]
                    [#if moduleId==module.id?string]${module.name}[#break/][/#if]
                  [/#list]
                [/#if]
              </a>
              <div class="dropdown-menu">
                [#list modules as module]
                <a class="dropdown-item" href="#" onclick="enableFilter('syllabus.module.id','${module.id}');return false;">${module.name}</a>
                [/#list]
                <a class="dropdown-item" href="#" onclick="resetFilter('syllabus.module.id');return false;">全部</a>
              </div>
            </li>
            [#assign natureId=Parameters['syllabus.nature.id']!""/]
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
                [#if natureId == '']课程性质
                [#else]
                  [#list natures as nature]
                    [#if natureId==nature.id?string]${nature.name}[#break/][/#if]
                  [/#list]
                [/#if]
              </a>
              <div class="dropdown-menu">
                [#list natures as nature]
                <a class="dropdown-item" href="#" onclick="enableFilter('syllabus.nature.id','${nature.id}');return false;">${nature.name}</a>
                [/#list]
                <a class="dropdown-item" href="#" onclick="resetFilter('syllabus.nature.id');return false;">全部</a>
              </div>
            </li>
          </ul>
        </nav>
      [/@]
    </div>
    <div class="card-body" style="padding-top: 0px;">
        <table class="table table-hover table-sm table-striped">
          <thead>
             <th>代码</th>
             <th>名称</th>
             <th>学分</th>
             <th>学时</th>
             <th>院系</th>
             <th>课程模块</th>
             <th>课程性质</th>
             <th>课程属性</th>
             <th>考核方式</th>
          </thead>
          <tbody >
          [#list syllabuses as syllabus]
           <tr>
            <td>${syllabus.course.code}</td>
            <td>
              [@b.a href="!info?id="+syllabus.id+"&semester.id="+semester.id target="_blank"]${syllabus.course.name}[/@]
              [#if syllabus.course.enName??]
              <span class="en_course_name" style="display:none;">${syllabus.course.enName}</span>
              [/#if]
            </td>
            <td>${syllabus.course.defaultCredits}</td>
            <td>
             ${syllabus.creditHours}
              [#if syllabus.hours?size>1]
                <span class="text-muted">([#list syllabus.hours?sort_by(['nature','code']) as ch]${ch.creditHours}[#if ch_has_next]+[/#if][/#list])</span>
              [/#if]
            </td>
            <td>${(syllabus.department.shortName)!syllabus.department.name}</td>
            <td>${(syllabus.module.name)!}</td>
            <td>${(syllabus.nature.name)!}</td>
            <td>${(syllabus.rank.name)!}</td>
            <td>${(syllabus.examMode.name)!}</td>
           </tr>
           [/#list]
          </tbody>
         </table>
         <nav aria-label="Page navigation example">
           <ul class="pagination float-right">
             [#if syllabuses.pageIndex > 1]
             <li class="page-item"><a class="page-link" href="#" onclick="listCourse(1)">首页</a></li>
             <li class="page-item"><a class="page-link" href="#" onclick="listCourse(${syllabuses.pageIndex-1})">${syllabuses.pageIndex-1}</a></li>
             [/#if]
             <li class="page-item active"><a class="page-link" href="#" >${syllabuses.pageIndex}</a></li>
             [#if syllabuses.pageIndex < syllabuses.totalPages]
             <li class="page-item"><a class="page-link" href="#" onclick="listCourse(${syllabuses.pageIndex+1})">${syllabuses.pageIndex+1}</a></li>
             <li class="page-item"><a class="page-link" href="#" onclick="listCourse(${syllabuses.totalPages})">末页</a></li>
             [/#if]
           </ul>
         </nav>
    </div>
  </div>
  <script>
     var qElem = document.searchForm['q'];
     qElem.focus();
     if(qElem.setSelectionRange && qElem.value.length>0){
       qElem.setSelectionRange(qElem.value.length,qElem.value.length)
     }
     function listCourse(pageIndex){
        bg.form.addInput(document.searchForm,"pageIndex",pageIndex);
        bg.form.submit(document.searchForm);
     }
     function enableFilter(name,value){
       bg.form.addInput(document.searchForm,name,value);
       bg.form.submit(document.searchForm);
     }
     function resetFilter(name){
       document.searchForm[name].value='';
       bg.form.submit(document.searchForm);
     }
  </script>
