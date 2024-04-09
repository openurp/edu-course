[#ftl]
[@b.head/]
[@b.toolbar title="学院课程资料维护"]
[/@]
<div class="search-container">
    <div class="search-panel">
        [@b.form name="courseSearchForm" action="!search" target="courselist" title="ui.searchForm" theme="search"]
            [@b.textfields names="course.code;代码"/]
            [@b.textfields names="course.name;名称"/]
            [@b.select style="width:100px" name="course.courseType.id" label="课程类别" items=courseTypes option="id,name" empty="..." /]
            [@b.select style="width:100px" name="course.nature.id" label="课程性质" items=courseNatures option="id,name" empty="..." /]
            [@b.select style="width:100px" name="course.category.id" label="课程分类" items=courseCategories option="id,name" empty="..." /]
            [#if departments?size > 1]
            [@b.select style="width:100px" name="course.department.id" label="所属院系" items=departments option="id,name" empty="..." /]
            [/#if]
            [@base.semester name="semester.id" label="开课学期" required="false" /]
            [@b.select style="width:100px" name="hasClazz" label="是否开课" items={"1":"是", "0":"否"} empty="..." /]
            [@b.select style="width:100px" name="hasProfile" label="课程简介" items={"1":"有", "0":"无"} empty="..." /]
            [@b.select style="width:100px" name="hasSyllabus" label="教学大纲" items={"1":"有", "0":"无"} empty="..." /]
            <input type="hidden" name="orderBy" value="course.code"/>
        [/@]
    </div>
    <div class="search-list">[@b.div id="courselist" href="!search?orderBy=course.code asc"/]
  </div>
</div>
[@b.foot/]
