  [@b.form action="!saveDesign" theme="list"]
    [@b.textfield name="design.subject" label="教学主题" required="true" value="" style="width:500px"/]
    [@b.textarea name="design.target" label="教学目标" required="true" value="" style="width:500px" rows="3"/]
    [@b.textarea name="design.emphasis" label="教学重点" required="true" value="" style="width:500px" rows="3"/]
    [@b.textarea name="design.difficulties" label="教学难点" required="true" value="" style="width:500px" rows="3"/]
    [@b.textarea name="design.resources" label="教学资源" required="false" value="" style="width:500px" rows="3"/]
    [@b.textarea name="design.values" label="课程思政融入点" required="false" value="" style="width:500px" rows="3"/]
    [@b.formfoot]
      <input type="hidden" name="program.id" value="${program.id}"/>
      <input type="hidden" name="design.idx" value="${design.idx}"/>
      [@b.submit value="保存"/]
    [/@]
  [/@]
