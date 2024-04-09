[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
<style>
  fieldset.listset li > label.title{
    min-width: 13rem;
  }
</style>
[#include "step.ftl"/]
[@displayStep ['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源'] 2/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveOutcomes"]
    [#list graduateObjectives as go]
      [@b.textarea label=go.name name="GO${go.id}.contents" value=(syllabus.getOutcome(go).contents)! cols="100" rows="3" maxlength="500" /]
    [/#list]
    [@b.field label="支撑矩阵"]
      [#assign orderedCourseObjectieves = syllabus.objectives?sort_by('code')/]
      <div style="margin-left: 10rem;max-width: 700px;">
      <table class="grid-table" style="text-align:center;">
        <tr>
          <td rowspan="2" style="width:150px"> 毕业要求（SR）</td><td colspan="${orderedCourseObjectieves?size}"> 课程目标</td>
        </tr>
        <tr>
          [#list orderedCourseObjectieves as co]<td>${co.code}</td>[/#list]
        </tr>

        [#list graduateObjectives as go]
          <tr>
            <td style="width:100px">【${go.name}】</td>
            [#list orderedCourseObjectieves as co]
            <td onMouseOver="overCell(this)" onMouseOut="outCell(this)" onclick="toggleCell(this)" id="${go.id}_${co.code}">[#if syllabus.getOutcome(go)?? && syllabus.getOutcome(go).support(co)]&#10004;[/#if]</td>
            [/#list]
          </tr>
        [/#list]
      </table>
      </div>
    [/@]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="topics"/>
      [#list graduateObjectives as go]
        <input type="hidden" name="GO${go.id}.courseObjectives" id="GO${go.id}.courseObjectives" value="${(syllabus.getOutcome(go).courseObjectives)!}"/>
      [/#list]
      <button class="btn btn-outline-primary btn-sm" onclick="history.back(-1);"><i class="fa fa-arrow-circle-left fa-sm"></i>上一步</button>
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
  <script>
    function overCell(cell){
      cell.style.backgroundColor="#f0f0f0";
    }
    function outCell(cell){
      cell.style.backgroundColor="";
    }
    function toggleCell(cell){
      var id = cell.id;
      var underscoreIdx= id.indexOf("_")
      var goId=id.substring(0,underscoreIdx)
      var coCode=id.substring(underscoreIdx+1)
      var hv = document.getElementById("GO"+goId+".courseObjectives");
      if(cell.innerHTML=="\u2714"){
        cell.innerHTML="";
        hv.value = hv.value.replace(coCode,"");
        hv.value = hv.value.replace(",,",",");
      }else{
        cell.innerHTML="&#10004";
        hv.value = (hv.value + "," + coCode);
      }
    }
  </script>
</div>
[@b.foot/]
