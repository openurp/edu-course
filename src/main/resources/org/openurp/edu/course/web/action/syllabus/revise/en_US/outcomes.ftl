[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="Course Syllabus Edit Form"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 2/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveOutcomes"]
    [#list syllabus.outcomes?sort_by("idx") as r]
      [@b.textarea label=r.title name="R${r.id}.contents" value=(r.contents)! cols="100" rows="3" maxlength="1000" required="true"/]
    [/#list]
    [@b.field label="支撑矩阵"]
      [#assign orderedCourseObjectieves = syllabus.objectives?sort_by('code')/]
      <div style="margin-left: 10rem;max-width: 800px;">
        <div class="text-muted">鼠标单击单元格，选中或取消</div>
        <table class="table table-sm table-bordered" style="text-align:center;">
          <tr>
            <td rowspan="2" style="width:150px"> Graduation requirements</td><td colspan="${orderedCourseObjectieves?size}"> Course Objectives</td>
          </tr>
          <tr>
            [#list orderedCourseObjectieves as co]<td>${co.code}</td>[/#list]
          </tr>

          [#list syllabus.outcomes?sort_by("idx") as r]
            <tr>
              <td style="width:100px">【${r.title}】</td>
              [#list orderedCourseObjectieves as co]
              <td onMouseOver="overCell(this)" onMouseOut="outCell(this)" onclick="toggleCell(this)" id="${r.id}_${co.code}"  title="点击选中或取消">[#if r.supportWith(co)]&#10004;[/#if]</td>
              [/#list]
            </tr>
          [/#list]
        </table>
        <div class="text-muted">
        说明：【毕业要求和课程目标的对应关系，可以是一个毕业要求和一个目标对应，即 “一对一”，也可以是多个课程目标对应
        某一个毕业要求，即“一对多”。在设定 毕业要求和课程目标关系时，公共课和学科专业基础课（如跨学院开设的课程）， 要做好对人才培养目标的支撑；
        每个专业应做好“课程地图”，特别是核心课程对 毕业要求的支撑关系，对某个毕业要求需要“强支撑”的课程必须将完成或达到该项要求作为课程目标。】
        </div>
      </div>
    [/@]
    [@b.formfoot]
      <input type="hidden" name="course.id" value="${course.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="step" value="topics"/>
      [#list syllabus.outcomes as r]
        <input type="hidden" name="R${r.id}.courseObjectives" id="R${r.id}.courseObjectives" value="${(r.courseObjectives)!}"/>
      [/#list]
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=objectives" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
      [@b.submit action="!saveOutcomes?justSave=1"]<i class="fa-solid fa-floppy-disk"></i>Save[/@]
      [@b.submit value="Save and move to the next step" /]
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
      var rId=id.substring(0,underscoreIdx)
      var coCode=id.substring(underscoreIdx+1)
      var hv = document.getElementById("R"+rId+".courseObjectives");
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
