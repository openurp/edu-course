  [@b.form name="copyCourseForm" action="!copy" target="course_list" theme="list"]
    [@b.field label="课程大纲"] ${syllabus.course.code} ${syllabus.course.name} <span class="text-muted">${syllabus.beginOn?string("yyyy-MM")}</span>[/@]
    [@b.select label="复制到" name="course.id" items=taskCourses style="width:300px" required="true" option=r"${item.code} ${item.name}"/]
    <input type="hidden" name="semester.id" value="${Parameters['semester.id']}"/>
    <input type="hidden" name="syllabus.id" value="${syllabus.id}"/>
  [/@]
