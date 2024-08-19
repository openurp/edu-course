[#ftl]
[@b.head/]
[#assign clazz = program.clazz/]
[@b.toolbar title="导入单次上课的教案"]bar.addBack();[/@]
  [@b.form action="!importDesign" theme="list" ]
    [@b.field  label="课程"]
       ${clazz.crn} ${clazz.course.code!} ${clazz.course.name!} ${clazz.course.defaultCredits!}学分 ${clazz.course.creditHours}学时
    [/@]
    [@b.file name="attachment" label="教案文件" required="true" extensions="docx"/]

    [@b.formfoot]
      <input type="hidden" name="program.id" value="${program.id}"/>
      <input type="hidden" name="idx" value="${idx}"/>
      [@b.submit value="action.submit"/]
    [/@]
  [/@]
[@b.foot/]
