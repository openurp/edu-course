[#ftl]
[@b.head/]
[@b.toolbar title="批量修改课程负责人"]bar.addBack();[/@]
  [@b.form action="!batchSave" theme="list"]
    [@b.field label="课程"]
      <div>
        [#list courseTasks as task]
          <input type="hidden" name="courseTask.id" value="${task.id}"/>
          ${task.course.name} (${task.course.code}) ${(task.director.name)!}
        [/#list]
      </div>
    [/@]
    [@b.select style="width:100px" name="office.id" label="教研室" items=offices option="id,name" empty="..." /]
    [@base.teacher name="teacher.id" label="负责人" required="false" value=""/]
    [@b.formfoot]
      [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
    [/@]
  [/@]
  [#list 1..20 as i]<br>[/#list]
[@b.foot/]
