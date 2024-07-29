[#ftl]
[@b.head/]
[@b.toolbar title="新开课程申请信息"]
  bar.addBack();
[/@]
[@b.messages slash="3"/]
<div class="container">
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h4 class="card-title">${apply.code!} ${apply.name} 申请内容</h4>
    </div>
    <table class="infoTable">
      <tr>
        <td class="title" width="10%">代码:</td>
        <td class="content">${apply.code!}</td>
        <td class="title" width="10%">名称:</td>
        <td class="content">${apply.name}</td>
        <td class="title" width="10%">院系:</td>
        <td class="content">${(apply.department.name)!}</td>
      </tr>
      <tr>
        <td class="title">课程性质:</td>
        <td class="content">${(apply.nature.name)!}</td>
        <td class="title">英文名:</td>
        <td class="content" colspan="3">${apply.enName!}</td>
      </tr>
      <tr>
        <td class="title">学分:</td>
        <td class="content">${apply.defaultCredits!}</td>
        <td class="title">学时:</td>
        <td class="content">${apply.creditHours!}</td>
        <td class="title">周课时:</td>
        <td class="content">${apply.weekHours!}</td>
      </tr>
      <tr>
        <td class="title">课程模块:</td>
        <td class="content">${(apply.module.name)!}</td>
        <td class="title">考试方式:</td>
        <td class="content">${(apply.examMode.name)!}</td>
        <td class="title">成绩记录方式:</td>
        <td class="content">${(apply.gradingMode.name)!}</td>
      </tr>
      <tr>
        <td class="title">生效日期:</td>
        <td class="content">${(apply.beginOn)!}</td>
        <td class="title">课程标签</td>
        <td class="content" colspan="3">
          [#list apply.tags as tag]
            ${tag.name}
            [#if tag_has_next],[/#if]
          [/#list]
        </td>
      </tr>
      <tr>
        <td class="title">状态:</td>
        <td class="content">${(apply.status)!}</td>
        <td class="title">申请人:</td>
        <td class="content">${(apply.applicant.name)!} ${apply.updatedAt}</td>
        <td class="title">审核意见:</td>
        <td class="content">${(apply.opinions)!}</td>
      </tr>
    </table>
  </div>
</div>
[@b.foot/]
