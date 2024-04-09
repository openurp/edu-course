[#ftl/]
[@b.head/]
<style>
  .card-header{
    padding:.5rem 1.25rem;
  }
  .info-table {
    width:100%;
    border: solid 0.5px black;
    text-align:center;
  }
  .info-table td{
    border:0.5px solid black;
  }
</style>
[#assign course=syllabus.course/]
<div class="container" style="font-family: 宋体;font-size: 12pt;padding:28mm 28mm;">
  <div style="width:100%;color:rgb(192,0,0);">
    <p style="font-weight:bold;font-family: 宋体;font-size: 16pt;">《${course.code} ${course.name}》</p>
    <p style="font-weight:bold;font-family: 楷体;font-size: 16pt;margin:0px;">【英文名称 ${course.enName!'--暂无--'}】</p>
  </div>
  <div>
    <table  style="width:100%;margin-top: 20px;">
      <tr>
        <td style="width:15%;text-align:right;">开课学期：</td>
        <td style="width:35%;border-bottom: solid 1px black;">${syllabus.semester.schoolYear}学年 ${syllabus.semester.name}学期</td>
        <td style="width:15%;text-align:right;">开课学院：</td>
        <td style="width:35%;border-bottom: solid 1px black;">${syllabus.department.name}</td>
      </tr>
    </table>
  </div>

  <div style="margin-top:30px;">
    <p style="width:100%;font-weight:bold;font-family: 宋体;font-size: 14pt;">一、基本信息</p>
    <p style="width:100%;font-weight:bold;font-family: 宋体;font-size: 14pt;">（一）课程基本情况</p>
  </div>

  <div>
    <table  class="info-table">
      <tr>
        <td rowspan="2" style="width:15%;">课程代码和名称</td>
        <td>中文</td>
        <td colspan="3" style="text-align:left;">${course.code} ${course.name}</td>
      </tr>
      <tr>
        <td>英文</td>
        <td colspan="3" style="text-align:left;">${course.enName!'----'}</td>
      </tr>
      <tr>
        <td rowspan="2">课程学分</td>
        <td rowspan="2">${course.defaultCredits}</td>
        <td rowspan="2">课程学时或实践周</td>
        <td>①总学时：<br>（其中，理论与实践学时）</td>
        <td>${course.creditHours}学时</td>
      </tr>
      <tr>
        <td>②总实践周：</td>
        <td>[#if course.weeks>0]${course.weeks}[/#if]</td>
      </tr>
      <tr>
        <td>课程性质</td>
        <td colspan="4"><input name="nature" style="width:100%" placeholder="从课程信息里面读取"/></td>
      </tr>
      <tr>
        <td>教学方式</td>
        <td colspan="4"><input name="nature" style="width:100%"/></td>
      </tr>
      <tr>
        <td>选用教材</td>
        <td colspan="2">
        <textarea name="nature" style="width:100%" rows="4"  placeholder="从教学任务里面读取"></textarea>
        </td>
        <td colspan="2"></td>
      </tr>
      <tr>
        <td colspan="5" style="padding: 0px;">
          <table style="width:100%;border: hidden;" >
            <tr>
              <td rowspan="2" style="width:15%;">课程教学活动安排</td>
              <td colspan="4">课堂学时</td>
              <td rowspan="2">考试周考核或自主考核*</td>
              <td rowspan="2">合计</td>
              <td rowspan="2">自主学习</td>
            </tr>
            <tr>
              <td>讲授</td><td>习题讲解</td><td>期中考试</td><td>案例讨论/项目训练</td>
            </tr>
            <tr>
              <td>本学期教学学时</td>
              <td><input name="1" style="width:100%"/></td>
              <td><input name="1" style="width:100%"/></td>
              <td><input name="1" style="width:100%"/></td>
              <td><input name="1" style="width:100%"/></td>
              <td><input name="1" style="width:100%"/></td>
              <td>${course.creditHours}</td>
              <td><input name="1" style="width:100%"/></td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td colspan="5" style="text-align:left;">
注：①该计划一式两份，经学院审批后，任课教师、学院各一份，并上传至网络教学平台的课程空间予以公布。②应选马工程教材的课程必须选马工程教材，并按教材组织教学。③教材选用必须符合学校教材选用管理的有关规定。④考试周考核或自主考核为考试周统一组织考试，或者根据教学安排需由教师自行组织的期末考核，一般为一个教学周与学分数相当的学时。
        </td>
      </tr>
    </table>
  </div>

</div>
[@b.foot/]
