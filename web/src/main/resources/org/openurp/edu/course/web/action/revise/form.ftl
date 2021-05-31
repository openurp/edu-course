[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程资料维护"]bar.addBack();[/@]
    [@b.form action=sa theme="list" action=b.rest.save(profile)]
      [@b.field label="课程"]${course.code} ${course.name} ${course.credits}学分[/@]
      [@b.field label="课程类别"]${(course.courseType.name)!'--'}[/@]
      [@b.field label="开课院系"]${(course.department.name)!'--'}[/@]
      [@b.textarea label="中文简介" name="profile.description" value=profile.description cols="100" rows="15" required="true" maxlength="500" comment="500字以内" placeholder="简述课程的目标、主要内容、获得的荣誉称号"/]
      [@b.textarea label="英文简介" name="profile.enDescription" value=profile.enDescription!  cols="100" rows="15" maxlength="500" comment="500字以内"/]
      [@b.formfoot]
        <input type="hidden" name="profile.course.id" value="${course.id}"/>
        [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
      [/@]
    [/@]
</div>
[@b.foot/]
