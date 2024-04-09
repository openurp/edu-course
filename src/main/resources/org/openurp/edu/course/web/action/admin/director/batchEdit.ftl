[#ftl]
[@b.head/]
[@b.toolbar title="批量修改课程负责人"]bar.addBack();[/@]
  [@b.form action="!batchSave" theme="list"]
    [@b.field label="课程"]
      <div>
        [#list directors as director]
          <input type="hidden" name="director.id" value="${director.id}"/>
          ${director.course.name} (${director.course.code}) ${(director.director.name)!}
        [/#list]
      </div>
    [/@]
    [@b.select name="office.id" label="专业/教研室" required="false" items=offices/]
    [@base.teacher name="teacher.id" label="负责人" required="false" value=""/]
    [@b.formfoot]
      [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
    [/@]
  [/@]
  [#list 1..20 as i]<br>[/#list]
[@b.foot/]
