[#ftl]
[@b.head/]
[@b.toolbar title="课程申请审核"]bar.addBack();[/@]
  [@b.form action="!audit" theme="list" onsubmit="validCreditHour"]
    [@b.textfield name="apply.name" label="名称" value="${apply.name!}" required="true" maxlength="100"/]
    [@b.textfield name="apply.enName" label="英文名" value="${apply.enName!}" maxlength="200" required="true" style="width:500px"/]
    [@b.field label="院系"]${apply.department.name}[/@]
    [@b.radios name="apply.module.id" label="课程模块" value=apply.module! items=modules required="true"/]
    [@b.radios name="apply.nature.id" label="理论/实践" value=apply.nature! items=natures required="true"/]
    [@b.radios name="apply.rank.id" label="选修必修" value=apply.rank! items=ranks empty="..." required="true"/]
    [@b.select name="apply.category.id" label="课程分类" value=apply.category! items=categories empty="..." required="true"/]

    [@b.textfield name="apply.defaultCredits" label="学分" onchange="autoCalcHours(this)" value=apply.defaultCredits! required="true" maxlength="20"/]
    [@b.textfield name="apply.creditHours" label="学时" value=apply.creditHours! required="true"  maxlength="100"/]
    [@b.textfield name="apply.weekHours" label="周课时" value=apply.weekHours! required="true" maxlength="20"/]
    [@b.textfield name="apply.weeks" label="周数" value=apply.weeks! maxlength="3"/]
    [#if teachingNatures?size>0]
    [@b.field label="分类学时" required="true"]
       [#assign hours={}/]
       [#list apply.hours as h]
          [#assign hours=hours+{'${h.nature.id}':h} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string].creditHours)!}">学时
        <input name="week${ht.id}" style="width:30px" id="teachingNature${ht.id}_w" value="${(hours[ht.id?string].weeks)!}">周
       [/#list]
    [/@]
    [/#if]
    [@b.radios name="apply.examMode.id" label="考核方式" value=apply.examMode! required="true" items=examModes /]
    [@b.radios name="apply.gradingMode.id" label="成绩记录方式" items=gradingModes value=apply.gradingMode! required="true" /]
    [@b.checkboxes name="tag.id" label="课程标签" values=apply.tags! items=tags  required="false" /]
    [@b.radios name="passed" value="1" label="是否同意" required="true" onclick="resetOpinion(this)"/]
    [@b.textarea name="apply.opinions" id="auditOpinion" required="true" rows="4" style="width:80%" value=apply.opinions!
                 label="审核意见" placeholder="请填写意见" value="同意"/]
    [@b.formfoot]
      <input type="hidden" name="apply.id" value="${apply.id}"/>
      [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
    [/@]
  [/@]
<script>
   function validCreditHour(form){
      [#if teachingNatures?size>0]
      var sumCreditHours=0;
      [#list teachingNatures as ht]
      sumCreditHours += Number.parseFloat(form['creditHour${ht.id}'].value||'0');
      [/#list]
      if(sumCreditHours != Number.parseFloat(form['apply.creditHours'].value||'0')){
         alert("分类学时总和"+sumCreditHours+",不等于课程学时"+form['apply.creditHours'].value);
         return false;
      }else{
         return true;
      }
      [#else]
      return true;
      [/#if]
   }
   [#assign hoursPerCredit=16/]
   [#--根据输入的学分自动计算周学时、学时和理论学时--]
   function autoCalcHours(creditInput){
     var form = creditInput.form;
     if(creditInput.value){
       var credits = parseFloat(creditInput.value);
       form['apply.creditHours'].value =  credits*${hoursPerCredit};
       form['apply.weekHours'].value =  credits;
       [#if teachingNatures?size>0]
          if(!form['creditHour${teachingNatures?first.id}'].value){
             form['creditHour${teachingNatures?first.id}'].value=form['apply.creditHours'].value;
          }
       [/#if]
     }
   }
    function resetOpinion(ele){
      var reject=jQuery(ele).val()=='0';
      if(reject) {
        jQuery("#auditOpinion").val('');
      }else{
        jQuery("#auditOpinion").val('同意');
      }
    }
</script>
[@b.foot/]
