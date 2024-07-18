<style>
ol {
  list-style: none outside none;
  margin: 0;
  padding: 0;
}

.ui-step {
  color: #b7b7b7;
  padding: 0 60px;
  margin-bottom: 35px;
  position: relative;
}
.ui-step:after {
  display: block;
  content: "";
  height: 0;
  font-size: 0;
  clear: both;
  overflow: hidden;
  visibility: hidden;
}
.ui-step li {
  float: left;
  position: relative;
}
.ui-step .step-end {
  width: 120px;
  position: absolute;
  top: 0;
  right: -60px;
}
.ui-step-line {
  height: 3px;
  background-color: #e0e0e0;
  box-shadow: inset 0 1px 1px rgba(0,0,0,.2);
  margin-top: 15px;
}
.step-end .ui-step-line { display: none; }
.ui-step-cont {
  width: 200px;
  position: absolute;
  top: 0;
  left: -15px;
  text-align: center;
}
.ui-step-cont-number {
  display: inline-block;
  position: absolute;
  left: 0;
  top: 0;
  width: 30px;
  height: 30px;
  line-height: 30px;
  color: #fff;
  border-radius: 50%;
  border: 2px solid rgba(224,224,224,1);
  font-weight: bold;
  font-size: 16px;
  background-color: #b9b9b9;
  box-shadow: inset 1px 1px 2px rgba(0,0,0,.2);
}
.ui-step-cont-text {
  position: relative;
  top: 34px;
  left: -88px;
  font-size: 12px;
}
.ui-step-3 li { width: 50%; }
.ui-step-4 li { width: 33.3%; }
.ui-step-5 li { width: 25%; }
.ui-step-6 li { width: 20%; }
.ui-step-7 li { width: 16.6%; }

.step-done .ui-step-cont-number { background-color: #667ba4; }
.step-done .ui-step-cont-text { color: #667ba4; }
.step-done .ui-step-line { background-color: #4c99e6; }
.step-active .ui-step-cont-number { background-color: #3c8dbc; }
.step-active .ui-step-cont-text { color: #3c8dbc;font-weight: bold; }

  fieldset.listset li > label.title{
    min-width: 10rem;
    max-width: 10rem;
  }
</style>
  [#assign stepNames=['填写基本信息','介绍和目标、价值引领','对毕业要求的支撑','课程教学内容与教学安排','学验并重的教学设计','课程考核方式与评分标准','教材和教学资源']/]
  [#assign links=[]/]
  [#if syllabus.id??]
  [#assign links=["!edit?id=${syllabus.id}","!edit?id=${syllabus.id}&step=objectives",
                  "!edit?id=${syllabus.id}&step=requirements","!edit?id=${syllabus.id}&step=topics",
                  "!edit?id=${syllabus.id}&step=designs","!assesses?syllabus.id=${syllabus.id}",
                  "!edit?id=${syllabus.id}&step=textbook"] /]
  [/#if]
  [#assign doneIndex = -1 /]

  [#if syllabus.topics?size>0][#assign doneIndex=3 /][/#if]
  [#if syllabus.designs?size>0][#assign doneIndex=4 /][/#if]
  [#if syllabus.assessments?size>0][#assign doneIndex=6 /][/#if]

  [#macro displayStep step_index]
  <div style="width:90%; margin:25px auto;margin-bottom: 50px;">
    <ol class="ui-step ui-step-${stepNames?size} ui-step-blue">
        [#list stepNames as data]
        [#assign stepDone = (data_index < step_index || data_index < doneIndex + 1 ) /]
      <li class="[#if data_index==0]step-start[#elseif data_index+1=stepNames?size]step-end[/#if] [#if data_index==step_index] step-active[/#if][#if stepDone] step-done[/#if]">
        <div class="ui-step-line"></div>
        <div class="ui-step-cont">
          [#if links?size > data_index && stepDone]
          [@b.a href=links[data_index]]
          <span class="ui-step-cont-number">${data_index+1}</span>
          <span class="ui-step-cont-text">${data}</span>
          [/@]
          [#else]
          <span class="ui-step-cont-number">${data_index+1}</span>
          <span class="ui-step-cont-text">${data}</span>
          [/#if]
        </div>
      </li>
      [/#list]
    </ol>
  </div>
  [/#macro]

[#assign tips={'syllabus.description':'必须含课程的德育描述','values':'经世济民、诚信服务等职业素养，课程根据思政教育和课程思政的安排，在本课程中融入的课程思政教学内容。'}/]
