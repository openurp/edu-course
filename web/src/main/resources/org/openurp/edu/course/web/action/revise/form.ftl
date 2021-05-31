[#ftl]
[@b.head/]
<div class="container">
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    [@b.form action=sa theme="list" action=b.rest.save(profile)]
      [@b.field label="课程"]${course.code} ${course.name} ${course.credits}学分[/@]
      [@b.field label="课程类别"]${(course.courseType.name)!'--'}[/@]
      [@b.field label="开课院系"]${(course.department.name)!'--'}[/@]
      [@b.textarea label="中文简介" name="profile.description" value=profile.description cols="80" rows="10" required="true" maxlength="500" comment="500字以内" placeholder="简述课程的目标、主要内容、获得的荣誉称号"/]
      [@b.textarea label="英文简介" name="profile.enDescription" value=profile.enDescription!  cols="80" rows="10" maxlength="500" comment="500字以内"/]
      [@b.field label="最新大纲"]
        [#if syllabuses?size>0]
        [#list syllabuses as s]
          ${s.semester.schoolYear}学年${s.semester.name}学期 ${s.author.name} 更新于${s.updatedAt?string("yyyy-MM-dd HH:mm")} [#list s.attachments as a][@b.a href="!attachment?file.id="+a.id target="_blank"]下载[/@][/#list]
        [/#list]
        [#else]尚无[/#if]
      [/@]
      [@b.field label="课程大纲作者"]
        <input name="syllabus.author.id" value="${author.id}" type="hidden">${author.name} <span style="color: red;">请上传已经审核通过的课程大纲附件</span>
      [/@]
      [@b.file label="大纲附件" name="attachment"/]
      [@b.formfoot]
        <input type="hidden" name="profile.course.id" value="${course.id}"/>
        [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
      [/@]
    [/@]
  </div>
</div>
[@b.foot/]
