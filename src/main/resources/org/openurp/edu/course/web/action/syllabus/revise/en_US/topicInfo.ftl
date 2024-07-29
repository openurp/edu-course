[@b.div id="div_topic_${topic.id}"]
  <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title">${topic.name!}
          <span class="text-muted text-sm">
          [#list topic.hours as h]${h.nature.enName}${h.creditHours} hours[#sep]&nbsp;[/#list]&nbsp;
          [#if topic.learningHours>0]Autonomous learning ${topic.learningHours} hours&nbsp;[/#if]
          ${topic.methods!}&nbsp;
          [#if topic.objectives??]Course Objectives:${topic.objectives?replace(",","&nbsp;")}[/#if]
          </span>
        </div>
        [@b.card_tools]
         <div class="btn-group">
         [@b.a href="!editTopic?topic.id=${topic.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>Edit[/@]
         [@b.a href="!removeTopic?topic.id=${topic.id}" onclick="return confirm('确定删除该主题?');" class="btn btn-sm btn-outline-danger"]<i class="fa fa-xmark"></i> Remove[/@]
         </div>
        [/@]
       [/@]
      <div class="card-body">
        [#if topic.exam && topic.hours?size==0]
         <p style="color:red;">建议${syllabus.examCreditHours}学时。理论、实践课时分布根据课程实际情况填写。当实际排课课时小于课程总学时的时候，建议填写考核课时（包括考试周统一考试，或自行组织的期末考核，一般为一个教学周与学分数相当的学时）</p>
        [/#if]
        <p style="white-space: preserve;">${topic.contents}</p>
        [#list topic.elements?sort_by(["label","code"]) as elem]
        <p style="white-space: preserve;"><span style="font-weight:bold;">${elem.label.enName}: </span>${elem.contents}</p>
        [/#list]
      </div>
  </div>
[/@]
