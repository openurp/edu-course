[@b.head/]
  <style>
    body{
      font-family: 宋体,Times New Roman;
    }
    .m0{
      margin:0px;
    }
    p{
      margin:0px;
    }
  .info-table {
    width:100%;
    border: solid 0.5px black;
  }
  .info-table td,th{
    border:0.5px solid black;
  }
  </style>
[#macro p contents=""]
<p style="white-space: preserve;text-indent:2em;"  class="mb-0">${contents}[#nested/]</p>
[/#macro]
[#macro multi_line_p contents=""]
  [#assign cnts]${contents!}[#nested/][/#assign]
  [#if cnts?length>0]
    [#assign ps = cnts?split("\n")]
    [#list ps as p]
    <p style="white-space: preserve;text-indent:2em;" class="mb-0">${p}</p>
    [/#list]
  [/#if]
[/#macro]

  [#assign semester=task.semester/]
  [#assign course=task.course/]
  [#assign tableIndex =1/]
  <div class="container">
    <p style="font-family:黑体;font-size:16.0pt;margin-top:0.88mm;text-align:center;">
      <span><b>课程目标达成情况评价分析报告</b></span>
    </p>
    <p class="m0 p2" style="font-size:14.0pt;text-align: center;"><span>${semester.schoolYear}学年第${semester.name}学期《${course.name}》</span></p>
    <p style="font-size:12.0pt;margin-top:2.75mm;"><b>一、 课程基本情况</b></p>
    <table class="grid-table">
      <colgroup>
        <col style="width:26.35mm;"><col style="width:30.46mm;"><col style="width:21.8mm;"><col style="width:28.82mm;"><col style="width:24.97mm;">
        <col style="width:38.09mm;">
      </colgroup>
      <tbody>
        <tr>
          <td class="text-center">课程代码</td>
          <td>${course.code}</td>
          <td class="text-center">课程名称</td>
          <td>${course.name}</td>
          <td class="text-center">课程学分/学时</td>
          <td>${course.defaultCredits}/${course.creditHours}</td>
        </tr>
        <tr>
          <td class="text-center">课程类别</td>
          <td colspan="2">${syllabus.stage.name}-${syllabus.module.name}-${syllabus.rank.name}-${syllabus.nature.name}</td>
          <td class="text-center">考核方式</td>
          <td colspan="2">${syllabus.examMode.name}</td>
        </tr>
        <tr>
          <td class="text-center">开课部门</td>
          <td colspan="2">${task.department.name}</td>
          <td class="text-center">课程负责人</td>
          <td colspan="2">${(task.director.name)!}</td>
        </tr>
      </tbody>
    </table>

    <p style="font-size:12.0pt;margin-top:2.75mm;"><b>二、 课程目标与毕业要求的对应关系</b></p>
    [@p]通过本课程学习，使学生掌握以下知识、能力和素质：[/@]
    [#list syllabus.objectives?sort_by("code") as co][@p]课程目标${co.code}：${co.contents}[/@][/#list]
    [@p]本课程对毕业要求的支撑：[/@]
    [#list syllabus.outcomes?sort_by(["idx"]) as o]
      [@p]毕业要求【${o.title}】：${o.contents}[/@]
    [/#list]

    [#assign orderedCourseObjectives = syllabus.objectives?sort_by('code')/]
    <table class="info-table" style="text-align:center;table-layout:fixed;">
      <caption style="caption-side: top;text-align: center;padding: 0px;">表 ${tableIndex}：课程目标和毕业要求的对应关系和支撑矩阵</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr>
          <th rowspan="2" style="width:250px"> 毕业要求</th><th colspan="${orderedCourseObjectives?size}"> 课程目标</th>
        </tr>
        <tr>
          [#list orderedCourseObjectives as co]<th>${co.code}</th>[/#list]
        </tr>
      </thead>
      [#list syllabus.outcomes?sort_by("idx") as o]
        <tr>
          <td>【${o.title}】</td>
          [#list orderedCourseObjectives as co]
          <td>[#if o.supportWith(co)]√[/#if]</td>
          [/#list]
        </tr>
      [/#list]
    </table>

    <p style="font-size:12.0pt;margin-top:2.75mm;"> <b>三、课程目标评价方式</b></p>
    [#assign usualAssessments=[]/]
    [#list syllabus.getAssessments(usualType)?sort_by("idx") as a]
      [#if a.component??][#assign usualAssessments=usualAssessments +[a]/][/#if]
    [/#list]
    [#assign orderedObjectives = syllabus.objectives?sort_by("code")/]
    [#assign usualAssess = syllabus.getAssessment(usualType,null)!/]
    [#assign endAssess = syllabus.getAssessment(endType,null)!/]
    [#assign endPercentMap = (endAssess.objectivePercentMap)!/]
    [@p]本课程对学生的学习成果进行形成性评价和结果性评价相结合，总成绩反映学生对课程掌握的总体情况。其中：平时成绩占${(usualAssess.weight)!}%，期末成绩占${(endAssess.weight)!}%。平时成绩构成见下表。[/@]

    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <caption style="caption-side: top;text-align: center;padding: 0px;">表 ${tableIndex}：课程考核项目及课程目标达成设计</caption>
      [#assign tableIndex=tableIndex+1/]
        <tr style="text-align:center;">
          <th>课程目标</th>
          [#list usualAssessments as a]<th>${a.component}</th>[/#list]
          [#if endAssess.weight>0]
          <th>期末考试</th>
          [/#if]
        </tr>
        [#list orderedObjectives as co]
        <tr>
          <td>课程目标${co.code}</td>
          [#assign coPercent=0/]
          [#if usualAssessments?size>0]
          [#list usualAssessments as a]
          [#assign percentMap = a.objectivePercentMap/]
          <td>[#if percentMap[co.code]??]√<span class="text-muted">${percentMap[co.code]}%</span>[#assign coPercent=coPercent+percentMap[co.code]/][#else]—[/#if]</td>
          [/#list]
          [/#if]
          <td>[#if endPercentMap[co.code]??]√<span class="text-muted">${(endPercentMap[co.code]!0)}%</span>[/#if]</td>
        </tr>
        [/#list]
    </table>

    <p style="font-size:12.0pt;margin-top:2.75mm;"> <b>四、课程目标期末考试试题分布</b></p>
    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <tr>
        <td>试题号</td><td>合计</td>[#list questionScores as qs]<td>${qs.questionIdx}</td>[/#list]
      </tr>
      [#assign totalScore=0/]
      [#list questionScores as qs][#assign totalScore=totalScore + qs.score/][/#list]
      <tr>
        <td>目标分值</td><td>${totalScore}</td>[#list questionScores as qs]<td>${qs.score}</td>[/#list]
      </tr>
    [#list orderedObjectives as co]
      <tr>
        <td>${co.code}</td>
        [#assign coTotalScore=0/]
        [#list questionScores as qs][#if qs.supportWith(co)][#assign coTotalScore=coTotalScore+qs.score/][/#if][/#list]
        <td>${coTotalScore}</td>
        [#list questionScores as qs]<td>[#if qs.supportWith(co)]√[/#if]</td>[/#list]
      </tr>
    [/#list]
    </table>

    <p style="font-size:12.0pt;margin-top:2.75mm;"> <b>五、考核成绩分析</b></p>

    <p style="font-size:12.0pt;margin-top:2.75mm;"> <b>六、课程目标达成评价结果</b></p>
    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <tr>
        <td>课程目标</td><td>评价方式</td><td>权重</td><td>目标分值</td><td>实际平均分</td><td>目标达成评价值</td>
      </tr>
      [#list orderedObjectives as co]
        [#assign hasEnd = (endPercentMap[co.code]!0)>0]
        [#assign usualCnt = 0/]
        [#list usualAssessments as a]
          [#if (a.objectivePercentMap[co.code]!0)>0 ]
          [#assign usualCnt = usualCnt +1 /]
          [/#if]
        [/#list]

        [#assign displayLabel=false/]
        [#assign coTotal=0.0/]
        [#assign coTotal=coTotal + endAssess.weight * (endPercentMap[co.code]!0)/]
        [#list usualAssessments as a]
          [#assign coTotal = coTotal + usualAssess.weight * (a.objectivePercentMap[co.code]!0)/]
        [/#list]

        [#if hasEnd]
        <tr>
          [#assign displayLabel=true/]
          <td rowspan="${usualCnt+1}">课程目标${co.code}</td>
          <td>期末考试</td>
          <td>${(endAssess.weight*(endPercentMap[co.code]!0)/coTotal)?string.percent}</td>
          [#assign coTotalScore=0/]
          [#assign coTotalAvgScore=0/]
          [#list questionScores as qs][#if qs.supportWith(co)][#assign coTotalScore=coTotalScore+qs.score/] [#assign coTotalAvgScore=coTotalAvgScore+qs.avgScore/][/#if][/#list]
          <td>${coTotalScore}</td>
          <td>${coTotalAvgScore}</td>
        </tr>
        [/#if]
        [#list usualAssessments as a]
          [#if (a.objectivePercentMap[co.code]!0)>0 ]
          <tr>
            [#if !displayLabel]<td rowspan="${usualCnt}">课程目标${co.code}</td>[#assign displayLabel=true/][/#if]
            <td>${a.component}</td>
            <td>${((usualAssess.weight * (a.objectivePercentMap[co.code]!0))*1.0/coTotal)?string.percent}</td>
            <td>${(a.objectivePercentMap[co.code]!0)}</td>
            <td>--</td>
            <td>--</td>
          </tr>
          [/#if]
        [/#list]
      [/#list]
    </table>
  </div>
[@b.foot/]
