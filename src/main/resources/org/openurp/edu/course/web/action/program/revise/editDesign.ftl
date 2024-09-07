<style>
  fieldset.listset li > label.title{
    min-width: 8rem;
    max-width: 8rem;
  }
</style>
  [#assign minSection=3/]
  [#if design.sections?size>minSection]
    [#assign minSection=design.sections?size/]
  [/#if]
  [@b.form action="!saveDesign" theme="list" onsubmit="validateSection" title="第${design.idx}次课的教案"]
    [@b.textfield name="design.subject" label="教学主题" required="true" value=design.subject! style="width:600px"/]
    [@b.textarea name="design.target" label="教学目标" required="true" value=design.get('target')! style="width:600px" rows="3" maxlength="4000"/]
    [@b.textarea name="design.emphasis" label="教学重点" required="true" value=design.get('emphasis')! style="width:600px" rows="3" maxlength="4000"/]
    [@b.textarea name="design.difficulties" label="教学难点" required="true" value=design.get('difficulties')! style="width:600px" rows="2" maxlength="4000"/]
    [@b.textarea name="design.resources" label="教学资源" required="false" value=design.get('resources')! style="width:600px" rows="3"/]
    [@b.textarea name="design.values" label="课程思政融入点" required="false" value=design.get('values')! style="width:600px" rows="3" maxlength="4000"/]
    [@b.textarea name="design.homework" label="课后作业" required="false" value=design.homework! style="width:600px" rows="4" maxlength="500"/]
    [#list 1..10 as sectionIndex]
      [@b.field label="教学环节${sectionIndex}"]填写第${sectionIndex}个教学环节内容<span id="section${sectionIndex}_tip" style="color:red"></span>[/@]
      [#assign required][#if sectionIndex==1]true[#else]false[/#if][/#assign]
      [@b.textfield name="sections["+sectionIndex+"].title" label="教学环节名称" required=required value=(design.getSection(sectionIndex).title)! style="width:400px" comment="不要填写序号，系统自编，类似一、二、三"/]
      [@b.number name="sections["+sectionIndex+"].duration" label="教学环节时间安排" required=required value=(design.getSection(sectionIndex).duration)! comment="分钟"/]
      [@b.editor theme="mini" name="sections["+sectionIndex+"].summary" label="教学内容提要" required=required value=(design.getSection(sectionIndex).summary)! style="width:600px" maxlength="50000" allowImageUpload="true" uploadJson="!uploadImage.json?program.id=${program.id}"/]
      [@b.editor theme="mini" name="sections["+sectionIndex+"].details" label="教学过程设计" required=required value=(design.getSection(sectionIndex).details)! style="width:600px" maxlength="50000" allowImageUpload="true" uploadJson="!uploadImage.json?program.id=${program.id}"/]
    [/#list]
    [@b.radios label="更多组" id="toggleSectionBtn" name="displayMore" value="0" items={'1':'显示', '0':'隐藏'} onclick="toggleSection(this)"/]

    [@b.formfoot]
      <input type="hidden" name="program.id" value="${program.id}"/>
      <input type="hidden" name="design.idx" value="${design.idx}"/>
      [@b.submit value="保存"/]
    [/@]
    <script>
      function toggleSection(ele){
        var show = jQuery("input[name='displayMore']:checked").val() == '1';
        var ol = jQuery("input[name='displayMore']").parents("ol");
        for(var i=7+${minSection}*5; i < 7+10*5;i++){
          if(show){
            ol.children("li:nth("+i+")").show();
          }else{
            ol.children("li:nth("+i+")").hide();
          }
        }
      }
      jQuery(function() {
        toggleSection(document.getElementById("toggleSectionBtn"));
      })
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
        if(minutes == ${design.creditHours*45}){
          return errorSections.length==0;
        }else{
          alert("总时间安排为"+minutes+"分钟，和${design.creditHours*45}分钟不符，请检查");
          return false;
        }
      }
    </script>
  [/@]
