[#ftl]
[@b.head/]
[@b.toolbar title="课程教学大纲修改"]
  bar.addBack();
[/@]
[#assign course=syllabus.course/]
  [@b.form theme="list" action=b.rest.save(syllabus) name="syllabusForm"]
    [@b.field label="课程"]${course.code} ${course.name} ${course.defaultCredits!}学分 ${syllabus.creditHours}学时[/@]
    [@b.radios label="语言" required="true" name="syllabus.docLocale"  style="width:200px;" items=locales value=(syllabus.docLocale)!/]
    [@b.field label="生效学期"]${syllabus.semester.schoolYear}学年${syllabus.semester.name}学期[/@]
    [@b.select name="syllabus.department.id" label="开课院系" value=syllabus.department! required="true"
               style="width:200px;" items=departments option="id,name" empty="..."/]
    [@b.radios name="syllabus.stage.id" label="学期阶段" value=syllabus.stage! required="true" items=calendarStages /]
    [@b.radios name="syllabus.module.id" label="课程模块" value=syllabus.module! items=courseModules empty="..." required="true"/]
    [@b.radios label="必修选修" name="syllabus.rank.id" value=syllabus.rank! items=courseRanks required="true"/]
    [@b.radios name="syllabus.nature.id" label="课程性质" value=syllabus.nature! items=courseNatures empty="..." required="true"/]
    [@b.textfield name="syllabus.methods" label="教学方法" value=syllabus.methods! required="true" style="width:300px" comment="多个方式请用、或者逗号隔开"/]
    [@b.radios name="syllabus.examMode.id" label="考核方式" value=syllabus.examMode! items=examModes /]
    [@b.radios name="syllabus.gradingMode.id" label="成绩记录方式" items=gradingModes value=syllabus.gradingMode!/]
    [@b.textfield name="syllabus.weeks" label="总实践周" value=syllabus.weeks!/]
    [@b.select name="syllabus.office.id" label="教研室" items=offices value=syllabus.office! option="id,name" empty="..." /]
    [@b.formfoot]
      [@b.submit value="保存" /]
    [/@]
  [/@]
[@b.foot/]
