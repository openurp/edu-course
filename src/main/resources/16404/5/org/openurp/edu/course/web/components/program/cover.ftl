  <div class="logo-container">
    <img src="${b.static_url('local','/images/logo_gray_red.png')}" width="100%"/>
  </div>
  <p style="font-family:黑体;font-size:26pt;text-align:center;">《${clazz.course.name}》</p>
  <p style="font-family:黑体;font-size:36pt;text-align:center;">课程教案</p>
  [#assign semesterNames={'1':'一','2':'二','3':'三','4':'四'}/]
  [#assign courseJournal = clazz.course.getJournal(clazz.semester)/]
  <p style="font-size:15pt;text-align:center;">&nbsp;</p>
  <p style="font-size:15pt;text-align:center;">（${clazz.semester.schoolYear}学年度 第${semesterNames[clazz.semester.name]}学期）</p>
  <table class="grid-table cover-table" style="width:90%;">
    <colgroup>
      <col width="15%"/>
      <col width="35%"/>
      <col width="15%"/>
      <col width="35%"/>
    </colgroup>
    <tr>
      <td class="title">开课学院</td><td>${clazz.teachDepart.name}</td><td class="title">教研室</td><td>${(plan.office.name)!}</td>
    </tr>
    <tr>
      <td class="title">课程代码</td><td>${clazz.course.code}</td><td class="title">英文名称</td><td>${(courseJournal.enName)!}</td>
    </tr>
    <tr>
      <td class="title">课程学分</td><td>${clazz.course.defaultCredits}学分</td><td class="title">课程学时</td>
      <td>
      总学时:${syllabus.creditHours}（[#list syllabus.hours as h]${h.nature.name}：${h.creditHours}[#sep]&nbsp;[/#list]）
      </td>
    </tr>
    <tr>
      <td class="title">任课教师</td><td colspan="3">[#list clazz.teachers as teacher]${teacher.name}&nbsp;[/#list]</td>
    </tr>
    <tr>
      <td class="title">课程性质</td><td colspan="3">${syllabus.stage.name} ${syllabus.module.name} ${syllabus.nature.name} ${syllabus.examMode.name}</td>
    </tr>
    <tr>
      <td class="title">教 学 班</td><td colspan="3">${clazz.clazzName}</td>
    </tr>
    <tr>
      <td class="title">教    材</td>
      <td colspan="3">
        [#list syllabus.textbooks as textbook]
          ${textbook.name} ${textbook.author!} ${(textbook.press.name)!} ${textbook.publishedOn?string("yyyy年MM月")} 版次：${(textbook.edition)!}
        [/#list]
      </td>
    </tr>
  </table>
