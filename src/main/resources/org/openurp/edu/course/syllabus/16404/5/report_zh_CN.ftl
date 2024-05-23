[#ftl/]
<!DOCTYPE html>
<html lang="zh_CN">
  <head>
    <title></title>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <meta http-equiv="expires" content="0"/>
    <meta http-equiv="content-style-type" content="text/css"/>
    <meta http-equiv="content-script-type" content="text/javascript"/>
    ${b.static.load(["jquery","beangle","bui","bootstrap"])}
 </head>
<body>
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
    body{
     width:170mm;
     margin:auto;
    }
    table {
     page-break-inside: avoid;
     max-width:170mm;
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
[#assign numSeq= ["一","二","三","四","五","六","七"] /]
[#assign tableIndex=1/]
[#macro header_title title]
  <p style="width:100%;font-weight:bold;font-family: 宋体;font-size: 14pt;">${title}</p>
[/#macro]

[#macro p contents=""]
<p style="white-space: preserve;">${contents}[#nested/]</p>
[/#macro]

[#assign course=syllabus.course/]

<div class="container" style="font-family: 宋体;font-size: 12pt;padding:0px 0px;">
  <table class="header">
    <tr><td><img src="${b.static_url('local','/images/logo.png')}" width="50px"/></td>
    <td style="text-align:right;vertical-align: bottom;">${syllabus.course.project.school.name}·课程教学大纲</td>
    </tr>
  </table>
  <div style="width:100%;color:rgb(192,0,0);">
    <p style="font-weight:bold;font-family: 宋体;font-size: 16pt;">《${course.code} ${course.name}》</p>
    <p style="font-weight:bold;font-family: 楷体;font-size: 16pt;margin:0px;">【英文名称 ${course.enName!'--暂无--'}】</p>
  </div>
  <div>
    <table  style="width:100%;margin-top: 20px;">
      <tr>
        <td style="width:15%;text-align:right;">开课学期：</td>
        <td style="width:35%;border-bottom: solid 1px black;" class="center">${syllabus.semester.schoolYear}学年 ${syllabus.semester.name}学期</td>
        <td style="width:15%;text-align:right;">开课学院：</td>
        <td style="width:35%;border-bottom: solid 1px black;" class="center">${syllabus.department.name}</td>
      </tr>
    </table>
  </div>

  <div style="margin-top:30px;">
    [@header_title "一、基本信息"/]
    [@header_title "（一）课程基本情况"/]
  </div>

  <div>
    <table  class="info-table">
      <tr>
        <td rowspan="2" style="width:15%;">课程代码和名称：</td>
        <td class="center">中文</td>
        <td colspan="3" style="text-align:left;">${course.code} ${course.name}</td>
      </tr>
      <tr>
        <td class="center">英文</td>
        <td colspan="3" style="text-align:left;">${course.enName!'----'}</td>
      </tr>
      <tr>
        <td rowspan="3">课程学分：</td>
        <td rowspan="3">${course.defaultCredits}</td>
        <td rowspan="3">课程学时或实践周</td>
        <td rowspan="2">①总学时：<br>（其中，理论与实践学时）</td>
        <td>${course.creditHours}学时</td>
      </tr>
      <tr>
        <td>其中：[#list syllabus.hours?sort_by(['nature','code']) as h]${h.nature.name}${h.creditHours}[#sep]，[/#list]</td>
      </tr>
      <tr>
        <td>②总实践周：</td>
        <td>[#assign weeks=0][#list syllabus.hours as h][#assign weeks=weeks+h.weeks][/#list][#if weeks>0]${weeks}周[/#if]</td>
      </tr>
      <tr>
        <td>课程性质：</td>
        <td colspan="4">
          ${syllabus.stage.name}-${syllabus.module.name}-${syllabus.rank.name}-${syllabus.nature.name}-${syllabus.examMode.name}
        </td>
      </tr>
      <tr>
        <td>教学方式：</td>
        <td colspan="4">${syllabus.methods!}</td>
      </tr>
      <tr>
        <td>开课院系：</td>
        <td colspan="4">${syllabus.department.name}</td>
      </tr>
      <tr>
        <td>先修课程：</td>
        <td colspan="4">${syllabus.prerequisites!}</td>
      </tr>
      <tr>
        <td>并修课程：</td>
        <td colspan="4">${syllabus.corequisites!}</td>
      </tr>
      <tr>
        <td>后续课程：</td>
        <td colspan="4">${syllabus.subsequents!}</td>
      </tr>
    </table>
  </div>

  <section style="margin-top:30px;">
    [@header_title "二、课程介绍和目标"/]
    <p style="white-space: preserve;">${syllabus.description}[#list syllabus.objectives?sort_by("code") as co]<br>    课程目标${co.code}：${co.contents}[/#list]</p>
  </section>

  <section style="margin-top:30px;">
    [@header_title "三、课程的价值引领"/]
    <p style="white-space: preserve;">    ${(syllabus.getText('values').contents)!}</p>
  </section>

  <div style="margin-top:30px;">
    [@header_title "四、课程对毕业要求的支撑"/]
    <p style="white-space: preserve;">[#t/]
    本课程对毕业要求的支撑：
[#list syllabus.outcomes?sort_by(["code"]) as o]
    毕业要求【${o.title}】：${o.contents}
[/#list]
    </p>[#t/]
    [#assign orderedCourseObjectives = syllabus.objectives?sort_by('code')/]
    <table class="info-table" style="text-align:center;table-layout:fixed;">
      <caption style="caption-side: top;text-align: center;">表 ${tableIndex}：课程目标和毕业要求的对应关系和支撑矩阵</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr>
          <th rowspan="2" style="width:250px"> 毕业要求</th><th colspan="${orderedCourseObjectives?size}"> 课程目标</th>
        </tr>
        <tr>
          [#list orderedCourseObjectives as co]<th>${co.code}</th>[/#list]
        </tr>
      </thead>
      [#list syllabus.outcomes?sort_by(["code"]) as o]
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
    [@header_title "五、课程教学内容与教学安排"/]
    [@header_title "（一）课程教学内容"/]
    <table class="info-table" style="table-layout:fixed;page-break-inside:auto;">
      <caption style="caption-side: top;text-align: center;">表 ${tableIndex}：本课程教学内容（实践项目）和学习成效</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th style="width:21mm">教学主题</th><th>教学内容（实践项目）和学习成效</th>
          <th style="width:21mm">教学方法</th>
        </tr>
      </thead>
      [#list syllabus.topics?sort_by("idx") as topic]
        <tr>
          <td>${topic.name}</td>
          <td>
          <p style="white-space: preserve;" class="m-0">${topic.contents}</p>
          [#list topic.elements?sort_by(["label","code"]) as elem]
          <p style="white-space: preserve;" class="m-0"><span style="font-weight:bold;">${elem.label.name}：</span><br/>${elem.contents}</p>
          [/#list]
          </td>
          <td>${topic.methods!}</td>
        </tr>
      [/#list]
    </table>
    <div style="margin-top: 20px;">&nbsp;</div>
    [@header_title "（二）教学安排"/]
    [#assign teachingNatures = syllabus.teachingNatures/]
    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <caption style="caption-side: top;text-align: center;">表 ${tableIndex}：课程教学安排</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th rowspan="3">教学主题</th><th style="width:${22*teachingNatures?size+1}mm" colspan="${teachingNatures?size+1}">课堂学时或实践周分布</th>
          <th style="width:22mm" rowspan="3">自主学习</th><th style="width:60mm" rowspan="3">对应课程教学目标</th>
        </tr>
        <tr>
          <th rowspan="2" style="width:22mm">小计</th><th style="width:${21*teachingNatures?size}mm" colspan="${teachingNatures?size}">其中：</th>
        </tr>
        <tr>
          [#list teachingNatures as nature]<th style="width:22mm">${nature.name}</th>[/#list]
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
        <td style="text-align:left;">课程考核</td>
        <td>${syllabus.examCreditHours}</td>
        [#list teachingNatures as nature]
          <td>[#list syllabus.examHours as eh][#if eh.nature==nature && eh.creditHours>0]${eh.creditHours}[#break/][/#if][/#list]</td>
        [/#list]
        <td></td>
        <td>——</td>
      </tr>
      [/#if]
      <tr>
        <td>合计</td>
        <td>${totalCreditHours}</td>
        [#list teachingNatures as nature]<td>[#assign h = syllabus.getCreditHours(nature) /][#if h>0]${h}[/#if]</td>[/#list]
        <td>[#if totalLearningHours>0]${totalLearningHours}[/#if]</td>
        <td>——</td>
      </tr>
      <tr>
        <td colspan="${4+teachingNatures?size}" style="text-align: left;">注：①在专业人才培养大纲中，学习方式为自主学习的课程，在“自主学习学时”栏填写学生根据教学主题需完成的学时；经学校批准进行线上线下混合式教学的课程，可设置自主学习学时。②理论学时或实践学时含考试周统一组织考试，或者根据教学安排需由教师自行组织的期末考核，一般为一个教学周与学分数相当的学时。</td>
      </tr>
    </table>
  </div>

  [#--教学内容--]
  <div style="margin-top:30px;">
    [@header_title "六、学验并重的教学设计"/]
    [#list syllabus.designs as design]
      [#assign title]（${numSeq[design.idx]}）${design.name}[/#assign]
      [@header_title title/]
      [@p design.contents/]
      [#if design.hasCase]
      <ul>案例：
      [#list syllabus.cases as c]<li>${c.idx+1}:${c.name}</li>[/#list]
      </ul>
      [/#if]
      [#if design.hasExperiment]
      <ul>实验：
      [#list syllabus.experiments as e]<li>${e.idx+1}:${e.name} ${e.experimentType.name} ${e.online?string("线上实验","线下实验")}</li>[/#list]
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
    [@header_title "七、课程考核方式与评分标准"/]
    [@header_title "（一）课程考核方式"/]
    [@header_title "&nbsp;&nbsp;1.课程成绩构成"/]
    [@p]
    本课程对学生的学习成果进行形成性评价和结果性评价相结合，总成绩反映学生对课程掌握的总体情况。其中：平时成绩占${usualAssess.scorePercent}%，期末成绩占${endAssess.scorePercent}%。平时成绩构成见下表。
    [/@]

    <table class="info-table" style="table-layout:fixed;text-align: center;">
      <caption style="caption-side: top;text-align: center;">表 ${tableIndex}：课程考核项目及课程目标达成设计</caption>
      [#assign tableIndex=tableIndex+1/]
      <thead>
        <tr style="text-align:center;">
          <th rowspan="2">类别</th><th rowspan="2">考核项目</th><th colspan="${usualAssessments?size}">平时成绩组成及结构</th>
          <th rowspan="2">平时成绩分布小计</th><th rowspan="2">平时成绩占总成绩比重</th>
          <th rowspan="2">期末成绩分布小计</th><th rowspan="2">期末成绩占总成绩比重</th>
          <th rowspan="2">总评成绩分布合计</th>
        </tr>
        <tr>
          [#list usualAssessments as a]<th>${a.component}</th>[/#list]
        </tr>
        <tr>
          <td rowspan="2">考核安排</td><td>考核次数</td>[#list usualAssessments as a]<th>${a.assessCount}</th>[/#list]
          <td>—</td><td>—</td><td>—</td><td>—</td><td>—</td>
        </tr>
        <tr>
          <td>考核分值占比</td>[#list usualAssessments as a]<th>${a.scorePercent}%</th>[/#list]
          <td>100%</td><td>${usualAssess.scorePercent}%</td><td>[#if endAssess.scorePercent>0]100%[#else]0%[/#if]</td>
          <td>${endAssess.scorePercent}%</td><td>100%</td>
        </tr>
        [#assign firstObj=orderedObjectives?first/]
        <tr>
          <td rowspan="${orderedObjectives?size}">课程目标</td><td>${firstObj.code}</td>
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
          <td colspan="2">考核方式小计</td>
          [#list usualAssessments as a]<th>${a.scorePercent}%</th>[/#list]
          <td>100%</td><td>${usualAssess.scorePercent}%</td><td>[#if endAssess.scorePercent>0]100%[#else]0%[/#if]</td>
          <td>${endAssess.scorePercent}%</td><td>100%</td>
        </tr>
        <tr>
          <td colspan="${7+usualAssessments?size}" style="text-align:left;">注：①平时成绩考核依托网络教学平台完成。②思想政治素质教育和诚信教育，融合在课程教学的全过程，根据课程实际进行课程考核。</td>
        </tr>
      </thead>
    </table>
      平时成绩考核评定依据如下:
      <ul style="list-style: none;">
      [#list usualAssessments as a]
        <li>（${a_index+1}）${a.component}${a.scorePercent}%，${a.assessCount}次。</li>
      [/#list]
      </ul>

    [@header_title "（二）主要考核方式的评分标准"/]
    [#assign assessIdx=0/]
    [#list usualAssessments as a]
      [#if !a.description?? && !a.scoreTable??][#continue/][/#if]
      [#assign title]${assessIdx+1}.${a.component}的评分标准[/#assign]
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
    [@header_title "八、教材和教学资源"/]
    [@header_title "（一）本课程使用教材"/]
      [#if syllabus.textbooks?size>0]
        [#list syllabus.textbooks as textbook]
          ${textbook.isbn} ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${(textbook.edition)!}
        [/#list]
      [#else]
        自编讲义
      [/#if]
    [@header_title "（二）参考书目"/]
    [@p syllabus.bibliography!"无"/]
    [@header_title "（三）本课程使用其他教学资源"/]
    [@p syllabus.materials!"无"/]
  </div>

  [#--课程教学大纲的审批--]
  <div style="margin-top:30px;">
    [@header_title "九、课程教学大纲的审批"/]
    <table>
      <tr>
        <td>编制人：</td>
        <td>${syllabus.writer.name}</td>
      </tr>
      <tr>
        <td>专业/教研室主任:</td>
        <td>${(syllabus.reviewer.name)!}</td>
      </tr>
      <tr>
        <td>教学院长:</td>
        <td>${(syllabus.approver.name)!}</td>
      </tr>
      <tr>
        <td>教学大纲启用时间:</td>
        <td>${syllabus.beginOn?string("yyyy年MM月")}</td>
      </tr>
    </table>
  </div>

</div><!--end container-->

[@b.foot/]