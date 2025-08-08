  [@b.toolbar title="修改实验项目"]
    bar.addItem("返回","toList()","action-backward");
    function toList(){
      bg.form.submit(document.expForm,"${b.url('!experiments?syllabus.id='+syllabus.id)}")
    }
  [/@]
  [@b.form action="!experiments" name="expForm"/]
  [#assign course=syllabus.course/]
  [@b.form theme="list" action="!saveExperiment" ]
    [@b.field label="课程"]${course.code} ${course.name} ${course.defaultCredits!}学分 ${course.creditHours}学时[/@]
    [@b.textfield name="experiment.name" label="实验名称" value=experiment.name! required="true" style="width:300px"/]
    [@b.number name="experiment.creditHours" label="学时" value=experiment.creditHours! required="true"/]
    [@b.select name="experiment.category.id" label="实验类别" items=categories value=experiment.category! empty="..." required="true" /]
    [@b.select name="experiment.experimentType.id" label="实验类型" items=experimentTypes value=experiment.experimentType! empty="..." required="true" /]
    [@b.select name="experiment.discipline.id" label="实验所属学科" items=disciplines value=experiment.discipline! empty="..." required="true" option=r"${item.code} ${item.name}"/]
    [@b.radios label="是否在线实验"  name="experiment.online" value=experiment.online items="1:common.yes,0:common.no" required="true"/]
    [@b.number label="每组人数" name="experiment.groupStdCount" value=experiment.groupStdCount required="true" min="1" max="50"/]

    [@b.formfoot]
      [#if experiment.id??]
      <input name="experiment.id" type="hidden" value="${experiment.id}"/>
      [/#if]
      <input name="syllabus.id" type="hidden" value="${syllabus.id}"/>
      [@b.submit value="保存" /]
    [/@]
  [/@]
  [#list 1..3 as i]<br>[/#list]
