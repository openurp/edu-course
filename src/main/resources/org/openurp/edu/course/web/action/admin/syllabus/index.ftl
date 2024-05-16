[#ftl]
[@b.head/]
[@b.toolbar title="教学大纲学院审核"]
[/@]
<div class="search-container">
    <div class="search-panel">
        [@b.form name="courseSearchForm" action="!search" target="courselist" title="ui.searchForm" theme="search"]
            [@base.semester name="semester.id" label="开课学期" required="true" value=semester /]
            [@b.textfields names="syllabus.course.code;代码"/]
            [@b.textfields names="syllabus.course.name;名称"/]
            [@base.code  name="syllabus.rank.id" type="course-ranks" label="必修选修" empty="..." /]
            [@base.code  name="syllabus.nature.id" type="course-natures" label="课程性质" empty="..." /]
            [#if departs?size > 1]
            [@b.select  name="course.department.id" label="开课院系" items=departs empty="..." /]
            [/#if]
            [@b.select  name="syllabus.status" label="状态" items=statuses empty="..." /]
            <input type="hidden" name="orderBy" value="syllabus.updatedAt desc"/>
        [/@]
    </div>
    <div class="search-list">[@b.div id="courselist" href="!search?orderBy=syllabus.updatedAt desc"/]
  </div>
</div>
[@b.foot/]
