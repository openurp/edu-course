  [@b.form theme="list" action="!saveTopic" target="_self"]
    [@b.textfield label="主题名" name="topic.name" value=topic.name! style="width:300px" required="true"/]
    [@b.textfield label="主题顺序" name="topic.idx"  value=topic.idx required="true"/]
    [@b.textarea label="教学内容" name="topic.contents" rows="5" cols="80" value=topic.contents! required="true" maxlength="3000"/]
    [#list topicLabels as label]
      [@b.textarea label=label.name name="element"+label.id rows="2" cols="80" value=(topic.getElement(label).contents)! required="true" maxlength="2000"/]
    [/#list]
    [@b.checkboxes label="教学方法" name="teachingMethod" items=teachingMethods values=topic.teachingMethods! required="true"/]
    [@b.field label="课时分布"]
      [#assign hours={}/]
      [#list topic.hours as h]
        [#assign hours=hours+{'${h.nature.id}':h} /]
      [/#list]

      [#list syllabus.teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">课时
        [#if ((syllabus.getHour(ht).weeks)!0)>0]
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">周
        [/#if]
      [/#list]
       <label for="learning_p">自主学习</label>
       <input name="topic.learningHours" style="width:30px" id="learning_p" value="${topic.learningHours}">课时
    [/@]
    [@b.checkboxes label="对应课程目标" name="objective.id" items=syllabus.objectives values=topic.matchedObjectives required="false"/]
    [@b.formfoot]
      <input type="hidden" name="topic.id" value="${topic.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [@b.submit value="保存" /]
    [/@]
  [/@]
