[#ftl/]
[@b.head/]
[@b.toolbar title="${syllabus.course.name}教学大纲"]
  bar.addClose();
[/@]
[@b.messages slash="3"/]
<style>
  .card-header{
    padding:.5rem 1.25rem;
  }
  .info-table {
    width:100%;
    border: solid 0.5px black;
  }
  .info-table td,th{
    border:0.5px solid black;
  }
  .score-table {
    width:100%;
    border: solid 0.5px black;
  }
  .score-table td,th{
    border:0.5px solid black;
  }
  .score-table tr:nth-child(1) {
    font-weight: bold;
    text-align: center;
  }
  .center{
    text-align:center;
  }
  p{
   line-height:2rem;
  }
  .header {
    width:100%;
    border-bottom: 1px solid;
    color:rgb(192,0,0);
    font-family: 楷体;
  }
  @media print {
    table {
     page-break-inside: avoid;
    }
    @page  {
      size: A4 portrait;
      margin: 1cm 2cm;
      @top-right {
        content: "Page " counter(page);
      }
    }
  }
</style>
[#assign numSeq= ["0","I","II","III","IV","V","VI","VII","VIII","IX"] /]
[#assign tableIndex=1/]
[#macro header_title title]
  <p style="width:100%;font-weight:bold;font-family: 宋体;font-size: 14pt;">${title}</p>
[/#macro]

[#macro p contents=""]
<p style="white-space: preserve;">${contents}[#nested/]</p>
[/#macro]

[#assign course=syllabus.course/]

<div class="container" style="font-family: 'Times New Roman',宋体;font-size: 12pt;padding:0px 0px;">
  <table class="header">
    <tr><td><img src="${b.static_url('local','/images/logo.png')}" width="50px"/></td>
    <td style="text-align:right;vertical-align: bottom;">${syllabus.course.project.school.enName}·Syllabus</td>
    </tr>
  </table>
  <div style="width:100%;color:rgb(192,0,0);">
    <p style="font-weight:bold;font-family: 宋体;font-size: 16pt;">《${course.code} ${course.enName!'--暂无--'}》</p>
  </div>
  <div>
    <table  style="width:100%;margin-top: 20px;">
      <tr>
        <td style="width:15%;text-align:right;">Semester：</td>
        <td style="width:35%;border-bottom: solid 1px black;" class="center">${syllabus.semester.schoolYear} ${syllabus.semester.name}</td>
        <td style="width:15%;text-align:right;">School：</td>
        <td style="width:35%;border-bottom: solid 1px black;" class="center">${syllabus.department.enName!syllabus.department.name}</td>
      </tr>
    </table>
  </div>

  <div style="margin-top:30px;">
    [@header_title "${numSeq[1]}、Basic information"/]
    [@header_title "（${numSeq[1]}）Course basic information"/]
  </div>

  <div>
    <table  class="info-table">
      <tr>
        <td style="width:15%;">Course code and name：</td>
        <td colspan="4" style="text-align:left;">${course.code} ${course.enName!'----'}</td>
      </tr>
      <tr>
        <td rowspan="3">Course credits：</td>
        <td rowspan="3" style="min-width:40px;">${course.defaultCredits}</td>
        <td rowspan="3">Course hours or practical weeks</td>
        <td rowspan="2">①Total hours<br>（Among them: theoretical hours and practical hours）</td>
        <td class="center">${course.creditHours}Hours</td>
      </tr>
      <tr>
        <td>Among them：[#list syllabus.hours?sort_by(['nature','code']) as h]${h.nature.enName} ${h.creditHours} [#sep]，[/#list]</td>
      </tr>
      <tr>
        <td>②Total practical weeks：</td>
        <td class="center">[#assign weeks=0][#list syllabus.hours as h][#assign weeks=weeks+h.weeks][/#list][#if weeks>0]${weeks}Weeks[/#if]</td>
      </tr>
      <tr>
        <td>Course nature：</td>
        <td colspan="4">
          ${syllabus.stage.enName}-${syllabus.module.enName!}-${syllabus.rank.enName!}-${syllabus.nature.enName!}-${syllabus.examMode.enName!}
        </td>
      </tr>
      <tr>
        <td>Teaching manners：</td>
        <td colspan="4">${syllabus.methods!}</td>
      </tr>
      <tr>
        <td>Responsible school：</td>
        <td colspan="4">${syllabus.department.enName!syllabus.department.name}</td>
      </tr>
      <tr>
        <td>Prerequisite course(s)：</td>
        <td colspan="4">${syllabus.prerequisites!}</td>
      </tr>
      <tr>
        <td>Synchronized course(s)：</td>
        <td colspan="4">${syllabus.corequisites!}</td>
      </tr>
      <tr>
        <td>Subsequent course(s)：</td>
        <td colspan="4">${syllabus.subsequents!}</td>
      </tr>
    </table>
  </div>

  <section style="margin-top:30px;">
    [@header_title "${numSeq[2]}、Course introduction and objectives"/]
    <p style="white-space: preserve;">${syllabus.description}[#list syllabus.objectives?sort_by("code") as co]<br>    Course objective ${co.code}：${co.contents}[/#list]</p>
  </section>

  <section style="margin-top:30px;">
    [@header_title "${numSeq[3]}、Course leading value"/]
    <p style="white-space: preserve;">    ${(syllabus.getText('values').contents)!}</p>
  </section>

  <div style="margin-top:30px;">
    [@header_title "${numSeq[4]}、Course supporting to graduation requirements"/]
    <p style="white-space: preserve;">[#t/]
    Supports of the course to graduation requirements：
[#list syllabus.outcomes?sort_by(["idx"]) as o]
    Graduation requirements【${o.title}】：${o.contents}
[/#list]
    </p>[#t/]
    [#assign orderedCourseObjectives = syllabus.objectives?sort_by('code')/]
    <table class="info-table" style="text-align:center;table-layout:fixed;">
      <caption style="caption-side: top;text-align: center;">Table ${tableIndex}：Corresponding relationship and supporting matrix between course objectives and graduation requirements</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr>
          <th rowspan="2" style="width:250px"> Graduation requirements </th><th colspan="${orderedCourseObjectives?size}"> Course objectives</th>
        </tr>
        <tr>
          [#list orderedCourseObjectives as co]<th>${co.code}</th>[/#list]
        </tr>
      </thead>
      [#list syllabus.outcomes?sort_by(["idx"]) as o]
        <tr>
          <td style="text-align:left;">【${o.title}】</td>
          [#list orderedCourseObjectives as co]
          <td>[#if o.supportWith(co)]&#10004;[/#if]</td>
          [/#list]
        </tr>
      [/#list]
    </table>
  </div>

  [#--教学内容--]
  <div style="margin-top:30px;">
    [@header_title "${numSeq[5]}、Course contents and schedule"/]
    [@header_title "（${numSeq[1]}）Course contents"/]
    <table class="info-table" style="table-layout:fixed;page-break-inside:auto;">
      <caption style="caption-side: top;text-align: center;">Table ${tableIndex}：Course contents (Practical project) and students’ learning outcome</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th style="width:21mm">Topics</th><th>Contents (Practical project) and students’ learning outcome</th>
          <th style="width:21mm">Teaching methods</th>
        </tr>
      </thead>
      [#list syllabus.topics?sort_by("idx") as topic]
        <tr>
          <td>${topic.name}</td>
          <td>
          <p style="white-space: preserve;" class="m-0">${topic.contents}</p>
          [#list topic.elements?sort_by(["label","code"]) as elem]
          <p style="white-space: preserve;" class="m-0"><span style="font-weight:bold;">${elem.label.enName}：<br/></span>${elem.contents}</p>
          [/#list]
          </td>
          <td>${topic.methods!}</td>
        </tr>
      [/#list]
    </table>
    <div style="margin-top: 20px;">&nbsp;</div>
    [@header_title "（${numSeq[2]}）Course schedule"/]
    [#assign teachingNatures = syllabus.teachingNatures/]
    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <caption style="caption-side: top;text-align: center;">Table ${tableIndex}：Course schedule</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th rowspan="3">Topics</th><th style="width:${22*teachingNatures?size+1}mm" colspan="${teachingNatures?size+1}">Teaching hours/practical weeks</th>
          <th style="width:22mm" rowspan="3">Autonomous learning hours</th><th style="width:22mm" rowspan="3">Course objective</th>
        </tr>
        <tr>
          <th rowspan="2" style="width:22mm">Sub-total</th><th style="width:${21*teachingNatures?size}mm" colspan="${teachingNatures?size}">Among them：</th>
        </tr>
        <tr>
          [#list teachingNatures as nature]<th style="width:22mm">${nature.enName!}</th>[/#list]
        </tr>
      </thead>
      [#assign totalCreditHours=0 /]
      [#assign totalLearningHours=0 /]
      [#list syllabus.topics?sort_by("idx") as topic]
        <tr>
          <td style="text-align:left;">${topic.name}</td>
          <td>
          [#assign creditHours=0/]
          [#list topic.hours as h]
          [#assign creditHours=creditHours + h.creditHours/]
          [/#list]
          ${creditHours}
          [#assign totalCreditHours=totalCreditHours + creditHours/]
          </td>
          [#list teachingNatures as nature]<td>${(topic.getHour(nature).creditHours)!}</td>[/#list]
          <td>[#if topic.learningHours>0]${topic.learningHours}[/#if]</td>
          [#assign totalLearningHours=totalLearningHours + topic.learningHours/]
          <td>${(topic.objectives?replace(","," "))!}</td>
        </tr>
      [/#list]
      [#if syllabus.examCreditHours>0]
       [#assign totalCreditHours=totalCreditHours + syllabus.examCreditHours/]
      <tr>
        <td style="text-align:left;">Course assessments</td>
        <td>${syllabus.examCreditHours}</td>
        [#list teachingNatures as nature]
          <td>[#list syllabus.examHours as eh][#if eh.nature==nature && eh.creditHours>0]${eh.creditHours}[#break/][/#if][/#list]</td>
        [/#list]
        <td></td>
        <td>——</td>
      </tr>
      [/#if]
      <tr>
        <td>Total</td>
        <td>${totalCreditHours}</td>
        [#list teachingNatures as nature]<td>[#assign h = syllabus.getCreditHours(nature) /][#if h>0]${h}[/#if]</td>[/#list]
        <td>[#if totalLearningHours>0]${totalLearningHours}[/#if]</td>
        <td>——</td>
      </tr>
      <tr>
        <td colspan="${4+teachingNatures?size}" style="text-align: left;">
        Note: ①In Education Guiding Schedule, the learning method of the course is “autonomous
        learning”, and the hours that students need to complete according to the teacher’s arrangement
        are filled in the column of “autonomous learning hours”; autonomous learning hours can be
        set for the courses approved officially for online and offline mixed teaching course. ②The
        theoretical hours or practical hours include final examination arranged officially or final
        evaluation conducted by teacher, which are generally equivalent to the course hours in one
        teaching week.
        </td>
      </tr>
    </table>
  </div>

  [#--教学内容--]
  <div style="margin-top:30px;">
    [@header_title numSeq[6]+"、Teaching design of integrity and practical wisdom"/]
    [#list syllabus.designs?sort_by("idx") as design]
      [#assign title]（${numSeq[design.idx+1]}）${design.name}[/#assign]
      [@header_title title/]
      [@p design.contents/]
      [#if design.hasCase]
      <ul>Cases：
      [#list syllabus.cases as c]<li>${c.idx+1}:${c.name}</li>[/#list]
      </ul>
      [/#if]
      [#if design.hasExperiment]
      <ul>Experiments：
      [#list syllabus.experiments as e]<li>${e.idx+1}:${e.name} [#if e.creditHours>0]${e.creditHours}hours [/#if]${e.experimentType.name} ${e.online?string("Online","Offline")}</li>[/#list]
      </ul>
      [/#if]
    [/#list]
  </div>

  [#--七、课程考核方式与评分标准--]
    [#assign usualAssessments=[]/]
    [#list syllabus.getAssessments(usualType)?sort_by("idx") as a]
      [#if a.component??][#assign usualAssessments=usualAssessments +[a]/][/#if]
    [/#list]
    [#assign orderedObjectives = syllabus.objectives?sort_by("code")/]
    [#assign usualAssess = syllabus.getAssessment(usualType,null)/]
    [#assign endAssess = syllabus.getAssessment(endType,null)/]
    [#assign endPercentMap = endAssess.objectivePercentMap/]
  <div style="margin-top:30px;">
    [@header_title numSeq[7]+"、Assessment manners and grading standards"/]
    [@header_title "（${numSeq[1]}）Assessment manners"/]
    [@header_title "&nbsp;&nbsp;1.Course assessment composition"/]
    [@p]
    This course combines formative evaluation and outcome evaluation, and the total
    scores reflects the students’ overall learning achievements. Among them, the usual
    score accounts for ${usualAssess.scorePercent} %, and the final grade accounts for ${endAssess.scorePercent} %. See the following
    table for the composition of usual score.
    [/@]

    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <caption style="caption-side: top;text-align: center;">Table ${tableIndex}：Course assessment and learning objective achievement design</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th rowspan="2">Classification</th><th rowspan="2">Evaluation items</th><th colspan="${usualAssessments?size}">Composition and structure of usual score</th>
          <th rowspan="2">Subtotal of usual score</th><th rowspan="2">Proportion of usual score to total score</th>
          <th rowspan="2">Subtotal of final score</th><th rowspan="2">Proportion of final score to total score</th>
          <th rowspan="2">Total score</th>
        </tr>
        <tr>
          [#list usualAssessments as a]<th>${a.component}</th>[/#list]
        </tr>
        <tr>
          <td rowspan="2">Examination arrangement</td><td>Evaluation frequency</td>[#list usualAssessments as a]<th>${a.assessCount}</th>[/#list]
          <td>—</td><td>—</td><td>—</td><td>—</td><td>—</td>
        </tr>
        <tr>
          <td>Proportion of assessment scores</td>[#list usualAssessments as a]<th>${a.scorePercent}%</th>[/#list]
          <td>100%</td><td>${usualAssess.scorePercent}%</td><td>[#if endAssess.scorePercent>0]100%[#else]0%[/#if]</td>
          <td>${endAssess.scorePercent}%</td><td>100%</td>
        </tr>
        [#assign firstObj=orderedObjectives?first/]
        <tr>
          <td rowspan="${orderedObjectives?size}">Course objectives</td><td>${firstObj.code}</td>
          [#assign coPercent=0/]
          [#list usualAssessments as a]
          [#assign percentMap = a.objectivePercentMap/]
          <td>[#if percentMap[firstObj.code]??]${percentMap[firstObj.code]}%[#assign coPercent=coPercent+percentMap[firstObj.code]/][#else]—[/#if]</td>
          [/#list]
          <td>${coPercent}%</td><td>${usualAssess.scorePercent}%</td><td>${(endPercentMap[firstObj.code]!0)}%</td><td>${endAssess.scorePercent}%</td>
          <td>${(coPercent*usualAssess.scorePercent + endAssess.scorePercent * (endPercentMap[firstObj.code]!0))/100}%</td>
        </tr>
        [#list orderedObjectives as co]
         [#if co_index==0][#continue/][/#if]
        <tr>
          <td>${co.code}</td>
          [#assign coPercent=0/]
          [#list usualAssessments as a]
          [#assign percentMap = a.objectivePercentMap/]
          <td>[#if percentMap[co.code]??]${percentMap[co.code]}%[#assign coPercent=coPercent+percentMap[co.code]/][#else]—[/#if]</td>
          [/#list]
          <td>${coPercent}%</td><td>${usualAssess.scorePercent}%</td><td>${(endPercentMap[co.code]!0)}%</td><td>${endAssess.scorePercent}%</td>
          <td>${(coPercent*usualAssess.scorePercent + endAssess.scorePercent * (endPercentMap[co.code]!0))/100}%</td>
        </tr>
        [/#list]
        <tr>
          <td colspan="2">Subtotal of assessment</td>
          [#list usualAssessments as a]<th>${a.scorePercent}%</th>[/#list]
          <td>100%</td><td>${usualAssess.scorePercent}%</td><td>[#if endAssess.scorePercent>0]100%[#else]0%[/#if]</td>
          <td>${endAssess.scorePercent}%</td><td>100%</td>
        </tr>
        <tr>
          <td colspan="${7+usualAssessments?size}" style="text-align:left;">
          Note: ①The process assessment is completed by the network teaching platform.②For
          Ideological and political quality education and honesty education are integrated in the
          whole process of the course, the process assessment shall be conducted by the course
          nature.
          </td>
        </tr>
      </thead>
    </table>
      The basis and standard of the assessment are as follows:
      <ul style="list-style: none;">
      [#list usualAssessments as a]
        <li>（${a_index+1}）${a.component} ${a.scorePercent}%</li>
      [/#list]
      </ul>

    [@header_title "（${numSeq[2]}）Scoring standard of main assessment methods"/]
    [#assign assessIdx=0/]
    [#list usualAssessments as a]
      [#if !a.description?? && !a.scoreTable??][#continue/][/#if]
      [#assign title]${assessIdx+1}. Grading standard of ${a.component}[/#assign]
      [#assign assessIdx=assessIdx+1/]
      [@header_title title/]
      [@p a.description!/]
      [#if a.scoreTable??]
        [#assign caption]<caption style="caption-side: top;text-align: center;">表 ${tableIndex}：${a.component}评分表</caption>[/#assign]
        [#assign tableIndex = tableIndex+1 /]
        [#assign scoreTable=a.updateScoreTable("<table class='score-table' style='text-align: left;'>",caption)/]
        ${scoreTable}
      [/#if]
    [/#list]
  </div>

  [#--教材和教学资源--]
  <div style="margin-top:30px;">
    [@header_title "${numSeq[8]}、Textbooks and teaching resources"/]
    [@header_title "（${numSeq[1]}）Textbooks used in the course"/]
      [#if syllabus.textbooks?size>0]
        [#list syllabus.textbooks as textbook]
          ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${textbook.publishedOn?string("yyyy-MM")} Edition:${(textbook.edition)!}
        [/#list]
      [#else]
        Using other teaching materials.
      [/#if]
    [@header_title "（${numSeq[2]}）Bibliographies"/]
    [@p syllabus.bibliography!"None"/]
    [@header_title "（${numSeq[3]}）Teaching resources used in the course"/]
    [@p syllabus.materials!"None"/]
  </div>

  [#--课程教学大纲的审批--]
  <div style="margin-top:30px;">
    [@header_title "${numSeq[9]}、Examination and approval"/]
    <table  style="width:400px">
      <tr>
        <td style="width:200px">Writer：</td>
        <td>${syllabus.writer.name}</td>
      </tr>
      <tr>
        <td>Reviewer:</td>
        <td>[#if syllabus.status.id==40||syllabus.status.id==50||syllabus.status.id==100||syllabus.status.id==200]${(syllabus.reviewer.name)!}[/#if] [#if submitable?? && submitable]<span class="notprint">[@b.a href="!submit?syllabus.id="+syllabus.id]提交审核[/@] </span>[/#if]</td>
      </tr>
      <tr>
        <td>Approver:</td>
        <td>[#if syllabus.status.id==50||syllabus.status.id==100||syllabus.status.id==200]${(syllabus.approver.name)!}[/#if]</td>
      </tr>
      <tr>
        <td>Start using time:</td>
        <td>${syllabus.beginOn?string("yyyy-MM-dd")}</td>
      </tr>
    </table>
  </div>
  [#if auditable?? && auditable]
    [@b.form name="auditForm" action="!audit" onsubmit="confirmSubmit"]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      <input type="hidden" name="toInfo" value="1"/>
      [@b.field label="状态"]${syllabus.status}[/@]
      [@b.submit value="驳回修改" action="!audit?passed=0" class="btn btn-warning"/]
      [@b.submit value="审批通过" action="!audit?passed=1" class="btn btn-success"/]
    [/@]
    <script>
      function confirmSubmit(form){
         return confirm("确认审核操作？");
      }
    </script>
  [/#if]
</div><!--end container-->

[@b.foot/]
