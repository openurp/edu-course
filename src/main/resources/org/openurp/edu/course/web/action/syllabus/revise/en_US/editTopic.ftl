  [@b.form theme="list" action="!saveTopic" target="_self"]
    [@b.textfield label="Topic Name" name="topic.name" value=topic.name! style="width:500px" required="true"/]
    [@b.textfield label="Index" name="topic.idx"  value=topic.idx required="true"/]
    [@b.textarea label="Contents" name="topic.contents" rows="5" cols="80" value=topic.contents! required="true"/]
    [#list topicLabels as label]
      [@b.textarea label=label.enName name="element"+label.id rows="2" cols="80" value=(topic.getElement(label).contents)! required="true" maxlength="800"/]
    [/#list]
    [@b.checkboxes label="Teaching methods" name="teachingMethod" items=teachingMethods values=topic.teachingMethods! required="true"/]
    [@b.field label="Teaching hours"]
      [#assign hours={}/]
      [#list topic.hours as h]
        [#assign hours=hours+{'${h.nature.id}':h} /]
      [/#list]

      [#list syllabus.teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}"> hours
        [#if ((syllabus.getHour(ht).weeks)!0)>0]
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}"> weeks
        [/#if]
      [/#list]
       <label for="learning_p">Autonomous learning</label>
       <input name="topic.learningHours" style="width:30px" id="learning_p" value="${topic.learningHours}"> hours
    [/@]
    [@b.checkboxes label="Course objective" name="objective.id" items=syllabus.objectives values=topic.matchedObjectives required="false"/]
    [@b.formfoot]
      <input type="hidden" name="topic.id" value="${topic.id}"/>
      <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
      [@b.submit value="Save" /]
    [/@]
  [/@]
