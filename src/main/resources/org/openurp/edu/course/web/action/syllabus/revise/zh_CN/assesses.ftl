[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 5/]

[#if ((syllabus.getAssessment(usualType,null).scorePercent)!0)>0]
  [#assign totalPercent=0/]
  [#list syllabus.getAssessments(usualType) as a]
    [#if a.component??][#assign totalPercent=totalPercent + a.scorePercent/][/#if]
  [/#list]
  [#if totalPercent!=100]
  <div class="alert alert-warning">平时组成部分百分总计${totalPercent}%,不足100%。</div>
  [/#if]
[/#if]

<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form name="assessForm" theme="list" action="!saveAssess"]
    [@b.textfield name="grade${usualType.id}.scorePercent" label="平时成绩百分比" value=(syllabus.getAssessment(usualType,null).scorePercent)! comment="%<span id='usual_comment'><span>" onchange="checkPercent()"/]
    [@b.textfield name="grade${endType.id}.scorePercent" label="期末成绩百分比" value=(syllabus.getAssessment(endType,null).scorePercent)! comment="%<span id='end_comment'><span>" onchange="checkPercent();checkEndCoPercent()"/]
    [@b.field label="期末对课程目标支撑比例"]
      [#assign endPercentMap={}/]
      [#if syllabus.getAssessment(endType,null)??]
        [#assign endPercentMap=syllabus.getAssessment(endType,null).objectivePercentMap/]
      [/#if]
      [#list syllabus.objectives?sort_by("code") as co]
        <label for="end_co${co.id}">${co.code}</label><input name="end_co${co.id}" type="number" style="width:50px"  value="${endPercentMap[co.code]!}" onchange="checkEndCoPercent()">
      [/#list]
      <span id="EndCoTip"></span>
    [/@]
      [#assign usualAssessments=[]/]
      [#list syllabus.getAssessments(usualType)?sort_by("idx") as a]
        [#if a.component??][#assign usualAssessments=usualAssessments +[a]/][/#if]
      [/#list]
      [#assign sectionIndex= ["一","二","三","四","五","六","七","八","九","十"] /]
      [#assign orderedObjectives = syllabus.objectives?sort_by("code")/]

      [#list usualAssessments as assessment]
        [#assign rnIndex=assessment_index/]
        <div class="card card-info card-primary card-outline" style="display: block;">
          [#assign rn=sectionIndex[rnIndex] /]
          [@b.card_header]
            <div class="card-title"><i class="fas fa-edit"></i>&nbsp;平时成绩--${assessment.component}</div>
            [@b.card_tools]
             <div class="btn-group">
             <a onclick="moveAssess('${assessment.id}');return false;" class="btn btn-sm btn-outline-primary"><i class="fa-solid fa-up-down"></i>上下移动</a>
             [@b.a href="!removeAssess?assessment.id="+assessment.id onclick="return confirm('确认删除该评分标准?')"  class="btn btn-sm btn-outline-danger"]<i class="fa fa-xmark"></i>删除[/@]
             </div>
            [/@]
           [/@]
          <div class="card-body">
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".component" label="平时环节"+rn value=assessment.component required="false" /]
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".scorePercent" label="占平时成绩比例" value=assessment.scorePercent comment="%" required="false" onchange="checkUsualCoPercent(${rnIndex})"/]
            [@b.field label="对课程目标支撑比例"]
              [#assign objectivePercentMap=assessment.objectivePercentMap/]
              [#list orderedObjectives as co]
                <label for="usual_${rnIndex}_co${co.id}">${co.code}</label><input name="usual_${rnIndex}_co${co.id}" id="usual_${rnIndex}_${co.id}" type="number" value="${objectivePercentMap[co.code]!}" style="width:50px" onchange="checkUsualCoPercent(${rnIndex})">
              [/#list]
                <span id="UsualCoTip${rnIndex}"></span>
            [/@]
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".assessCount" label="考核次数" value=assessment.assessCount /]
            [@b.textarea name="grade${usualType.id}_"+rnIndex+".description" label="评分标准" rows="4" cols="80" style="width:650px" maxlength="2000" value=assessment.description! required="false"]
              <a class="btn btn-sm btn-outline-primary" onclick="return toggleScoreTable(this)">
                [#if assessment.scoreTable??]<i class="fa fa-minus"></i>评分表[#else]<i class="fa fa-plus"></i>评分表[/#if]
              </a>
            [/@]
            [#assign editorstyle="width:650px;height:300px;display:none"/]
            [#if assessment.scoreTable??]
            [#assign editorstyle="width:650px;height:300px;"/]
            [/#if]
            [@b.editor theme="mini" name="grade${usualType.id}_"+rnIndex+".scoreTable" label="评分表" rows="7" cols="80" style=editorstyle maxlength="20000" value=assessment.scoreTable!/]
          </div>
        </div>
      [/#list]

      [#if 7>usualAssessments?size]
      [#list usualAssessments?size..6 as rnIndex]
        <div class="card card-info card-primary card-outline" style="display: block;">
          [#assign rn=sectionIndex[rnIndex] /]
          [@b.card_header]
            <div class="card-title"><i class="fas fa-edit"></i>&nbsp;平时成绩--环节${rn}</div>
           [/@]
          <div class="card-body">
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".component" label="平时环节"+rn value="" required="false" /]
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".scorePercent" label="占平时成绩比例" value="" comment="%" required="false" onchange="checkUsualCoPercent(${rnIndex})"/]
            [@b.field label="对课程目标支撑比例"]
              [#list orderedObjectives as co]
                <label for="usual_${rnIndex}_co${co.id}">${co.code}</label><input name="usual_${rnIndex}_co${co.id}" id="usual_${rnIndex}_${co.id}" type="number" style="width:50px" onchange="checkUsualCoPercent(${rnIndex})">
              [/#list]
                <span id="UsualCoTip${rnIndex}"></span>
            [/@]
            [@b.textfield name="grade${usualType.id}_"+rnIndex+".assessCount" label="考核次数" value="" /]
            [@b.textarea name="grade${usualType.id}_"+rnIndex+".description" label="评分标准" rows="4" cols="80" style="width:650px" maxlength="2000" value="" required="false"]
              <a class="btn btn-sm btn-outline-primary" onclick="return toggleScoreTable(this)"><i class="fa fa-plus"></i>评分表</a>
            [/@]
            [@b.editor theme="mini" name="grade${usualType.id}_"+rnIndex+".scoreTable" label="评分表" rows="7" cols="80" style="width:650px;heigth:300px;display:none" maxlength="20000" value="" /]
          </div>
        </div>
      [/#list]
      [/#if]
    [@b.formfoot]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="textbook"/>
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=designs" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit action="!saveAssess?justSave=1"]<i class="fa-solid fa-floppy-disk"></i>保存[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  <script>
    function checkUsualCoPercent(idx){
      var form = document.assessForm;
      var percent=form["grade${usualType.id}_"+idx+".scorePercent"].value;
      var totalPercent=Number.parseInt(percent);
      var coTotalPercent=0;
      var coPercent="";
      [#list syllabus.objectives?sort_by("code") as co]
        coPercent = form["usual_"+idx+"_co${co.id}"].value
        if(coPercent){
          coTotalPercent += Number.parseInt(coPercent);
        }
      [/#list]
      if(Number.isNaN(totalPercent)){
        document.getElementById("UsualCoTip"+idx).innerHTML="分项累计为"+coTotalPercent+"%";
        form["grade${usualType.id}_"+idx+".scorePercent"].value=coTotalPercent;
        document.getElementById("UsualCoTip"+idx).style.color="";
      }else if(totalPercent!=coTotalPercent){
        document.getElementById("UsualCoTip"+idx).innerHTML="分项累计为"+coTotalPercent+"%和该项占比"+totalPercent+"%不相等";
        document.getElementById("UsualCoTip"+idx).style.color="red";
      }else{
        document.getElementById("UsualCoTip"+idx).innerHTML="分项累计为"+coTotalPercent+"%和该项占比"+totalPercent+"%相等";
        document.getElementById("UsualCoTip"+idx).style.color="green";
      }
    }
    function checkEndCoPercent(){
      var form = document.assessForm;
      var percent=form["grade${endType.id}.scorePercent"].value;
      var totalPercent=Number.parseInt(percent);
      var coTotalPercent=0;
      var coPercent="";
      [#list syllabus.objectives?sort_by("code") as co]
        coPercent = form["end_co${co.id}"].value
        if(coPercent){
          coTotalPercent += Number.parseInt(coPercent);
        }
      [/#list]
      if(Number.isNaN(totalPercent) || totalPercent==0){
        if(coTotalPercent>0){
          document.getElementById("EndCoTip").innerHTML="不需要为期末成绩设置支撑比例，因为期末成绩占比为0%";
          document.getElementById("EndCoTip").style.color="red";
        }else{
          document.getElementById("EndCoTip").innerHTML=""
        }
      }else{
        if(coTotalPercent!=100){
          document.getElementById("EndCoTip").innerHTML="期末成绩设置支撑比例总和应为100%，现在为"+coTotalPercent+"%";
          document.getElementById("EndCoTip").style.color="red";
        }else{
          document.getElementById("EndCoTip").innerHTML="支撑比例综合100%";
          document.getElementById("EndCoTip").style.color="green";
        }
      }
    }
    function checkPercent(){
      var form = document.assessForm;
      var totalPercent=0;
      var percent = form['grade${usualType.id}.scorePercent'].value
      if(percent){
        totalPercent += Number.parseInt(percent);
      }
      percent = form['grade${endType.id}.scorePercent'].value
      if(percent){
        totalPercent += Number.parseInt(percent);
      }
      if(totalPercent!=100){
        document.getElementById("end_comment").innerHTML="期末平时累计"+totalPercent+"%不等于100%";
        document.getElementById("end_comment").style.color="red";
      }else{
        document.getElementById("end_comment").innerHTML="";
      }
    }
    function toggleScoreTable(elem){
      var scoreLi = elem.parentNode.nextElementSibling;
      if(scoreLi.style.display=="none"){
        scoreLi.style.display=""
        elem.innerHTML="<i class='fa fa-minus'></i>评分表";
      }else{
        scoreLi.style.display="none";
        elem.innerHTML="<i class='fa fa-plus'></i>评分表";
        scoreLi.querySelectorAll("textarea").forEach(function(x) {x.value="";})
        var i=0;
        var cnNodes= elem.childNodes;
        while(i < cnNodes.length){
          if(cnNodes[i].tagName=="TEXTAREA"){
            cnNodes[i].value="";
            break;
          }
          i+=1;
        }
      }
    }
    function moveAssess(assessId){
      var idx = prompt("请输入需要移动到第几个位置？1表示第一个位置？",1);
      if(idx){
        var form = document.assessForm;
        if(idx<1 || idx > ${usualAssessments?size}){
          alert("输入的序号不合法，只能输入1~${usualAssessments?size}范围的数字。");
        }else{
          var url = "${b.url('!moveAssess')}?assessment.id="+assessId+"&idx="+idx;
          bg.form.submit(form,url);
        }
      }
    }
    [#list usualAssessments as ua]
      checkUsualCoPercent(${ua_index});
      checkEndCoPercent();
    [/#list]
  </script>
  </div>
</div>
[@b.foot/]
