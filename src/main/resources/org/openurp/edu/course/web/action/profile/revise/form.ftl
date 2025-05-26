[#ftl]
[@b.head/]
<div class="container">
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">基本信息</h4>
    </div>
    [@b.form name="profileForm" theme="list" action=b.rest.save(profile) onsubmit="validateTextbook"]
      [@b.field label="课程"]${course.code} ${course.name} ${course.defaultCredits}学分[/@]
      [@b.field label="英文名"]${course.enName!}[/@]
      [@b.field label="课程类别"]${(course.courseType.name)!'--'}[/@]
      [@b.field label="开课院系"]${(course.department.name)!'--'}[/@]
      [@b.field label="修订学期"]${profile.semester.schoolYear}学年度${profile.semester.name}学期[/@]
      [@b.textarea label="课程简介" name="profile.description" value=profile.description cols="80" rows="10" required="true" maxlength="500" comment="500字以内" placeholder="简述课程的目标、主要内容、获得的荣誉称号"/]
      [@b.textarea label="英文简介" name="profile.enDescription" value=profile.enDescription! cols="80" rows="10" maxlength="500" comment="500字以内"/]
      [@b.textfield label="先修课程" name="profile.prerequisites" value=profile.prerequisites! maxlength="500" placeholder="没有可忽略" style="width:400px;"/]
      [@b.field label="已有大纲"]
        [#if syllabusDocs?size>0]
        [#list syllabusDocs as s]
          ${s.semester.schoolYear}学年${s.semester.name}学期 ${s.writer.name} 更新于${s.updatedAt?string("yyyy-MM-dd HH:mm")} [@b.a href="!attachment?doc.id="+s.id target="_blank"]下载[/@]
          [#if s.writer.id=writer.id]<span style="color: red;">上传后将会覆盖此大纲</span>[/#if]
          <br>
        [/#list]
        [#else]尚无[/#if]
      [/@]
      [@b.field label="课程大纲作者"]
        <input name="syllabusDoc.writer.id" value="${writer.id}" type="hidden">${writer.name} <span style="color: red;">请确认大纲已经所属系部审核。</span>
      [/@]
      [@b.file label="更新大纲" name="attachment" extensions="doc,docx,pdf" maxSize="20M"/]
      [#assign bookAdoptions={'1':'使用教材','2':'使用讲义','3':'使用参考资料'}/]
      [@b.radios label="教材选用类型" name="profile.bookAdoption" items=bookAdoptions value=profile.bookAdoption.id?string required="true"/]
      [@base.textbook name="textbook.id" label="教材" required="false" style="width:600px;" values=profile.books  multiple="true" empty="..."/]
      [@b.field label="添加新的教材"]
        如果找不到教材，可以
        <a href="/base/admin/edu/new-book/new?project.id=${course.project.id}" data-toggle="modal" data-target="#newBookDiv" title="添加出版物教材">添加新的出版教材</a>，
        <a href="/base/admin/edu/new-book/new?project.id=${course.project.id}&lecture=1" data-toggle="modal" data-target="#newBookDiv" title="添加讲义">添加新的讲义</a>
      [/@]
      [@b.textarea label="参考资料" name="profile.bibliography" value=profile.bibliography! cols="80" rows="5" maxlength="500"/]
      [@b.textarea label="其他教学资源" name="profile.materials" value=profile.materials! cols="80" rows="5" maxlength="500" placeholder="网址或者链接"/]
      [@b.textfield label="课程网站地址" name="profile.website" value=profile.website!  maxlength="200" style="width:400px;"/]
      [@b.formfoot]
        <input type="hidden" name="profile.course.id" value="${course.id}"/>
        <input type="hidden" name="profile.semester.id" value="${profile.semester.id}"/>
        <input type="hidden" name="semester.id" value="${semester.id}"/>
        [@b.submit value="action.submit"/]
      [/@]
    [/@]
  </div>
</div>
[@b.dialog title="新增出版物/讲义" id="newBookDiv"/]
<script>
  function validateTextbook(form){
    if(form['profile.bookAdoption'].value=='1'){
      var selectBooks = $('select[name="textbook\.id"] option:selected').val();
      if(!selectBooks){
        alert("请选择教材");
        return false;
      }
    }
    return true;
  }
</script>
[@b.foot/]
