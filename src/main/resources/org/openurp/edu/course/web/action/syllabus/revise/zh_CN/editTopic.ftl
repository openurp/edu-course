  [@b.form theme="list" action="!saveTopic" target="_self"]
    [#assign changeTopicExam]changeTopicExam(this.value);[/#assign]
    [#if topic.id??][#assign changeTopicExam]changeTopicExam${topic.id}(this.value);[/#assign][/#if]
    [@b.radios label="教学环节" name="topic.exam" value=topic.exam items="0:课堂教学,1:考查考试" onclick=changeTopicExam/]
  [#if topic.exam]
    [@b.textfield label="名称" name="topic.name" value=topic.name! style="width:300px" required="true"/]
    [@b.textfield label="顺序号" name="topic.idx"  value=topic.idx required="true"/]
    [@b.textarea label="内容" name="topic.contents" rows="5" cols="80" value=topic.contents! required="false" maxlength="3000"/]
  [#else]
    [@b.textfield label="主题名" name="topic.name" value=topic.name! style="width:300px" required="true"/]
    [@b.textfield label="顺序号" name="topic.idx"  value=topic.idx required="true"/]
    [@b.textarea label="教学内容" name="topic.contents" rows="5" cols="80" value=topic.contents! required="true" maxlength="3000"/]
    [#list topicLabels as label]
      [@b.textarea label=label.name name="element"+label.id rows="2" cols="80" value=(topic.getElement(label).contents)! required="true" maxlength="2000"/]
    [/#list]
    [@b.checkboxes label="教学方法" name="teachingMethod" items=teachingMethods values=topic.teachingMethods! required="true"/]
  [/#if]
    [@b.field label="学时分布"]
      [#assign hours={}/]
      [#list topic.hours as h]
        [#assign hours=hours+{'${h.nature.id}':h} /]
      [/#list]

      [#list syllabus.teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">学时
        [#if ((syllabus.getHour(ht).weeks)!0)>0]
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">周
        [/#if]
      [/#list]
       <label for="learning_p">自主学习</label>
       <input name="topic.learningHours" style="width:30px" id="learning_p" value="${topic.learningHours}">学时
    [/@]
  [#if !topic.exam]
    [@b.checkboxes label="对应课程目标" name="objective.id" items=syllabus.objectives?sort_by("code") values=topic.matchedObjectives required="true"/]
  [/#if]
    [@b.formfoot]
      [#if topic.id??]<input type="hidden" name="topic.id" value="${topic.id}"/>[/#if]
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [@b.submit value="保存" /]
    [/@]
  [/@]
  <script>
   [#if topic.id??]
     function changeTopicExam${topic.id}(examValue){
       bg.Go("${b.url("!editTopic?syllabus.id=${syllabus.id}")}&topic.exam="+examValue+"&topic.id=${topic.id}","div_topic_${topic.id}");
     }

   [#else]
     function changeTopicExam(examValue){
       bg.Go("${b.url("!newTopic?syllabus.id=${syllabus.id}")}&topic.exam="+examValue,"new_topic_card");
     }
   [/#if]
  </script>
