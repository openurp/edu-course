[#ftl]
[@b.head/]
[@b.toolbar title="修改课程负责人"]bar.addBack();[/@]
  [@b.form action=b.rest.save(director) theme="list"]
    [@b.field label="课程"]${director.course.name}(${director.course.code})[/@]
    [@b.select name="director.office.id" label="专业/教研室" required="false" items=offices value=director.office!/]
    [@base.teacher name="director.id" label="负责人" value=director.director! required="false"/]
    [@b.formfoot]
      [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
    [/@]
  [/@]
  [#list 1..20 as i]<br>[/#list]
[@b.foot/]