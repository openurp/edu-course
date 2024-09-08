[#ftl]
[@b.head/]
[@b.grid items=clazzPrograms var="clazzProgram"]
  [@b.gridbar]
    bar.addItem("选中下载",action.multi("download","选择数量较多时,下载时间较长，请稍后",null,"_blank"));
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="6%" property="clazz.crn" title="课程序号"/]
    [@b.col width="10%" property="clazz.course.code" title="课程代码"/]
    [@b.col property="clazz.course.name" title="课程名称"]
      [@b.a href="!info?id="+clazzProgram.id target="_blank"]${clazzProgram.clazz.course.name}[/@]
    [/@]
    [@b.col width="8%" property="clazz.teachDepart.name" title="开课院系"]
      ${clazzProgram.clazz.teachDepart.shortName!clazzProgram.clazz.teachDepart.name}
    [/@]
    [@b.col width="10%" property="writer.name" title="编写人"/]
    [@b.col width="10%" property="designCount" title="进度"]
      ${clazzProgram.designCount}/${clazzProgram.lessonCount} <span class="inlinepie" values="${clazzProgram.designCount},${clazzProgram.lessonCount-clazzProgram.designCount}"></span>
    [/@]
    [@b.col width="15%" property="clazz.courseType.name" title="课程类别"/]
    [@b.col width="6%" property="clazz.course.defaultCredits" title="学分"/]
    [@b.col width="6%" property="clazz.course.creditHours" title="学时"/]
  [/@]
[/@]
<script>
beangle.register("${b.base}/static/",{
  "sparkline":{js:"edu/course/js/jquery.sparkline.min.js"}
});
bg.load(["sparkline"],function(){
  jQuery(document).ready(function(){
    $('.inlinepie').sparkline('html', {type: 'pie',sliceColors:['green','red']});
  });
});
</script>
[@b.foot/]
