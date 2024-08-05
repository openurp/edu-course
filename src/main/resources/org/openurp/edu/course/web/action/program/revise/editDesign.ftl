<style>
  fieldset.listset li > label.title{
    min-width: 7rem;
    max-width: 7rem;
  }
</style>
  [@b.form action="!saveDesign" theme="list" onsubmit="validateSection"]
    [@b.textfield name="design.subject" label="教学主题" required="true" value=design.subject! style="width:600px"/]
    [@b.textarea name="design.target" label="教学目标" required="true" value=design.get('target')! style="width:600px" rows="3"/]
    [@b.textarea name="design.emphasis" label="教学重点" required="true" value=design.get('emphasis')! style="width:600px" rows="3"/]
    [@b.textarea name="design.difficulties" label="教学难点" required="true" value=design.get('difficulties')! style="width:600px" rows="2"/]
    [@b.textarea name="design.resources" label="教学资源" required="false" value=design.get('resources')! style="width:600px" rows="3"/]
    [@b.textarea name="design.values" label="课程思政融入点" required="false" value=design.get('values')! style="width:600px" rows="3"/]
    [@b.textarea name="design.homework" label="课后作业" required="false" value=design.homework! style="width:600px" rows="4"/]
    [#list 1..10 as sectionIndex]
      [@b.field label="第${sectionIndex}部分"]填写第${sectionIndex}部分内容<span id="section${sectionIndex}_tip" style="color:red"></span>[/@]
      [#assign required][#if sectionIndex==1]true[#else]false[/#if][/#assign]
      [@b.textfield name="sections["+sectionIndex+"].title" label="教学环节名称" required=required value=(design.getSection(sectionIndex).title)! style="width:600px" comment="不要填写序号，系统自编，类似一、二、三"/]
      [@b.number name="sections["+sectionIndex+"].duration" label="教学环节时间安排" required=required value=(design.getSection(sectionIndex).duration)! comment="分钟"/]
      [@b.editor theme="mini" name="sections["+sectionIndex+"].summary" label="教学内容提要" required=required value=(design.getSection(sectionIndex).summary)! style="width:600px" maxlength="4000" allowImageUpload="true"/]
      [@b.editor theme="mini" name="sections["+sectionIndex+"].details" label="教学过程设计" required=required value=(design.getSection(sectionIndex).details)! style="width:600px" maxlength="4000" allowImageUpload="true"/]
    [/#list]
    [@b.formfoot]
      <input type="hidden" name="program.id" value="${program.id}"/>
      <input type="hidden" name="design.idx" value="${design.idx}"/>
      [@b.submit value="保存"/]
    [/@]
    <script>
      function validateSection(form){
        var errorSections=[];
        var minutes=0;
        for(var i=1;i<=10;i++){
          var title = form["sections["+i+"].title"];
          if(title){
            var title = form["sections["+i+"].title"].value;
            var messages = ""
            if(title.length>0){
              var duration = form["sections["+i+"].duration"].value;
              var h = Number.parseInt(duration);
              if(isNaN(h) || h<=0){
                messages+="时长填写正整数;"
              }else{
                minutes += h;
              }
              var summary = form["sections["+i+"].summary"].value;
              if(summary.length==0){
                messages+="请填写摘要;"
              }
              var details = form["sections["+i+"].details"].value;
              if(details.length==0){
                messages+="教学过程设计;"
              }
              jQuery("#section"+i+"_tip").html(messages);
              if(messages.length>0){
                errorSections.push(i);
              }
            }
          }
        }
        if(errorSections.length>0){
          alert("第"+errorSections.join(",")+"小节的部分填写有误，请检查！");
        }
        return errorSections.length==0;
        //if(minutes
      }
    </script>
  [/@]