[@b.div id="div_topic_${topic.id}"]
  <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title">${topic.name!}
          <span class="text-muted text-sm">
          [#list topic.hours as h]${h.nature.enName}[#if h.creditHours>0] ${h.creditHours} hours[#else][#if h.weeks>0] ${h.weeks} weeks[/#if][/#if][#sep]&nbsp;[/#list]&nbsp;
          [#if topic.learningHours>0]Autonomous learning {topic.learningHours} hours&nbsp;[/#if]
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
        <p style="white-space: preserve;">${topic.contents}</p>
        [#list topic.elements?sort_by(["label","code"]) as elem]
        <p style="white-space: preserve;"><span style="font-weight:bold;">${elem.label.enName}: </span>${elem.contents}</p>
        [/#list]
      </div>
  </div>
[/@]
