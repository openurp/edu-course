[#ftl]
[@b.head/]
[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]<div class="container">[/#if]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    [@b.form action=sa theme="list" action=b.rest.save(profile)]
      [@b.field label="课程"]${course.code} ${course.name} ${course.credits}学分[/@]
      [@b.field label="课程类别"]${(course.courseType.name)!'--'}[/@]
      [@b.field label="开课院系"]${(course.department.name)!'--'}[/@]
      [@b.textarea label="课程简介" name="profile.description" value=profile.description cols="80" rows="10" required="true" maxlength="500" comment="500字以内" placeholder="简述课程的目标、主要内容、获得的荣誉称号"/]
      [@b.textarea label="英文简介" name="profile.enDescription" value=profile.enDescription!  cols="80" rows="10" maxlength="500" comment="500字以内"/]
      [@b.field label="已有大纲"]
        [#if syllabuses?size>0]
        [#list syllabuses as s]
          ${s.semester.schoolYear}学年${s.semester.name}学期 ${s.author.name} 更新于${s.updatedAt?string("yyyy-MM-dd HH:mm")} [#list s.attachments as a][@b.a href="!attachment?file.id="+a.id target="_blank"]下载[/@][/#list]
          [#if s.author.id=author.id]<span style="color: red;">上传后将会覆盖此大纲</span>[/#if]
          <br>
        [/#list]
        [#else]尚无[/#if]
      [/@]
      [@b.field label="课程大纲作者"]
        <input name="syllabus.author.id" value="${author.id}" type="hidden">${author.name} <span style="color: red;">请确认大纲已经教研室、学院审核，上传后将直接发布给全校师生查看。</span>
      [/@]
      [@b.file label="更新大纲" name="attachment" extensions="doc,docx,pdf" maxSize="10M"/]
      [@b.formfoot]
        <input type="hidden" name="profile.course.id" value="${course.id}"/>
        [@b.submit value="action.submit"/]
      [/@]
    [/@]
  </div>
[#if !(request.getHeader('x-requested-with')??) && !Parameters['x-requested-with']??]</div>[/#if]
[@b.foot/]
