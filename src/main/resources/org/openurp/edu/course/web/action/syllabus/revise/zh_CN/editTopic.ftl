          [@b.form theme="list" action="!saveTopic"]
            [@b.textfield label="主题名" name="topic.name" value=topic.name! required="true"/]
            [@b.textfield label="主题顺序" name="topic.idx"  value=topic.idx required="true"/]
            [@b.textarea label="教学内容" name="topic.contents" rows="4" cols="80" value=topic.contents! required="true"/]
            [#list topicLabels as label]
              [@b.textarea label=label.name name="element"+label.id rows="3" cols="80" value=(topic.getElement(label).contents)! required="true"/]
            [/#list]
            [@b.select label="对应课程目标" name="objective.id" items=syllabus.objectives values=(topic.objectives!"")?split(",") required="false" multiple="true"/]
            [@b.select label="教学方法" name="teachingMethod.id" items=teachingMethods values=topic.methods required="false" multiple="true"/]
            [@b.field label="分类课时"]
               [#assign hours={}/]
               [#list topic.hours as h]
                  [#assign hours=hours+{'${h.nature.id}':h} /]
               [/#list]
               [#list teachingNatures as ht]
                <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
                <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">课时
                <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">实践周
               [/#list]
            [/@]
            [@b.formfoot]
              <input type="hidden" name="topic.id" value="${topic.id}"/>
              <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
              [@b.submit value="保存" /]
            [/@]
          [/@]
