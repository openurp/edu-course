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
    [@b.field label="填写说明"]
    <div style="margin-left: 10rem;" class="text-muted">
      <p>
        1.通识课、数学课、学科专业基础课（含跨学科跨专业选修课）请从“人才培养方案指导意见附表1：通识课、数学课、学科基础课与毕业要求对应关系”中通
        用知识、能力、素质中选择课程需要支撑的毕业要求。通用知识、能力、素质全校统一分为 8 个方面，请不要改变顺序。
        例如某门课程支撑的是【思想政治素质】、【诚信品质】、【创新意识】，就仅保留这几项毕业要求（其他在本课程未支撑的毕业要求可以删除），并结合课
        程和该项毕业要求进行具体描述。同时，将毕业要求课程目标和毕业要求的对应关系和支撑矩阵.
      </p>
      <p style="margin-bottom:0px">
        2.专业课请根据专业培养方案设定的知识、能力、素质的毕业要求，选择课程需要支撑的毕业要求。
        例如某门课程支撑的是 【思想品质】、【团队合作】、【实践能力】就仅保留这几项毕业要求（其他在本课程未支撑的毕业要求可以删除），
        并结合将毕业要求分解给课程的培养要求进行具体描述。同时，将毕业要求课程目标和毕业要求的对应关系和支撑矩阵。
      </p>
    </div>
    [/@]
    [#list graduateObjectives as go]
      [@b.textarea label=go.name name="GO${go.id}.contents" value=(syllabus.getOutcome(go).contents)! cols="100" rows="5" maxlength="800" /]
    [/#list]
    [@b.field label="支撑矩阵"]
      [#assign orderedCourseObjectieves = syllabus.objectives?sort_by('code')/]
      <div style="margin-left: 10rem;max-width: 700px;">
        <div class="text-muted">鼠标单击单元格，选中或取消</div>
        <table class="grid-table" style="text-align:center;">
          <tr>
            <td rowspan="2" style="width:150px"> 毕业要求（SR）</td><td colspan="${orderedCourseObjectieves?size}"> 课程目标</td>
          </tr>
          <tr>
            [#list orderedCourseObjectieves as co]<td>${co.code}</td>[/#list]
          </tr>

          [#list graduateObjectives as go]
            <tr>
              <td style="width:100px">${go.code}【${go.name}】</td>
              [#list orderedCourseObjectieves as co]
              <td onMouseOver="overCell(this)" onMouseOut="outCell(this)" onclick="toggleCell(this)" id="${go.id}_${co.code}"  title="点击选中或取消">[#if syllabus.getOutcome(go)?? && syllabus.getOutcome(go).supportWith(co)]&#10004;[/#if]</td>
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
      [#list graduateObjectives as go]
        <input type="hidden" name="GO${go.id}.courseObjectives" id="GO${go.id}.courseObjectives" value="${(syllabus.getOutcome(go).courseObjectives)!}"/>
      [/#list]
      [@b.a href="!edit?syllabus.id=${syllabus.id}&step=objectives" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>Previous step[/@]
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
