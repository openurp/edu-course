[@b.div id="div_topic_${topic.id}"]
  <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title">${topic.name!}
          <span class="text-muted text-sm">
          [#list topic.hours as h]${h.nature.name}${h.creditHours}学时[#sep]&nbsp;[/#list]&nbsp;
          [#if topic.learningHours>0]自主学习${topic.learningHours}学时&nbsp;[/#if]
          ${topic.methods!}&nbsp;
          [#if topic.objectives??]对应课程目标:${topic.objectives?replace(",","&nbsp;")}[/#if]
          </span>
        </div>
        [@b.card_tools]
         <div class="btn-group">
         [@b.a href="!editTopic?topic.id=${topic.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>修改[/@]
         [@b.a href="!removeTopic?topic.id=${topic.id}" onclick="return confirm('确定删除该主题?');" class="btn btn-sm btn-outline-danger"]<i class="fa fa-xmark"></i>删除[/@]
         </div>
        [/@]
       [/@]
      <div class="card-body">
        [#if topic.exam]<p style="white-space: preserve;">内容：${topic.contents}</p>
        [#else]<p style="white-space: preserve;">教学内容：${topic.contents}</p>
        [/#if]
        [#list topic.elements?sort_by(["label","code"]) as elem]
        <p style="white-space: preserve;">${elem.label.name}：${elem.contents}</p>
        [/#list]
      </div>
  </div>
[/@]
