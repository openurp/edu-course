[@b.head/]
<div class="container" style="overflow: scroll;">
  [#assign semesterName][#if semester.startWeek<25]春夏（上半年）[#else]秋冬（下半年）[/#if][/#assign]
  <h5 style="text-align:center;">${project.school.name} ${semester.year.name} 学年度 ${semester.name} 学期 课程教材汇总</h5>
  <table class="table table-sm table-mini" style="width:2530px;" id="report_table">
    <colgroup>
      <col width="100px">
      <col width="80px">
      <col width="110px">
      <col width="130px">
      <col width="110px">
      <col width="240px">
      <col width="110px">

      <col width="50px"> <!--学分-->
      <col width="120px">
      <col width="60px">
      <col width="240px"> <!--教材-->
      <col width="150px">
      <col width="100px">
      <col width="150px">
      <col width="80px">
      <col width="50px"> <!--版次-->
      <col width="60px">
      <col width="60px">
      <col width="120px"><!--境外教材类别-->
      <col width="120px">
      <col width="90px">
      <col width="100px">
      <col width="100px">
    </colgroup>
    <thead>
      <tr>
        <th>高校名称</th>
        <th>学年</th>
        <th>学期</th>
        <th>开课院系</th>
        <th>课程号</th>
        <th>课程名称</th>
        <th>课程类别</th>
        <th>学分</th>
        <th>课程负责人</th>
        <th>课程面向对象</th>
        <th>教材名称</th>
        <th>国际标准书号（ISBN）</th>
        <th>教材主编姓名</th>
        <th>出版单位</th>
        <th>出版年月</th>
        <th>版本</th>
        <th>教材面向学段</th>
        <th>校自编/校外编</th>
        <th>境外教材类别</th>
        <th>教材类型</th>
        <th>教材所属学科门类</th>
        <th>教材形态</th>
        <th>出版社级别</th>
      </tr>
    </thead>
    <tbody>
      [#list tasks as task]
        [#if textbooks.get(task.course)?? && textbooks.get(task.course)?size>0]
        [#list textbooks.get(task.course) as book]
      <tr>
        <td>${project.school.name}</td>
        <td>${task.semester.year.name}</td>
        <td>${semesterName}</td>
        <td>${task.department.name}</td>
        <td>${task.course.code}</td>
        <td>${task.course.name}</td>
        <td>${task.courseType.name}</td>
        <td>${task.course.defaultCredits}</td>
        <td>[#list task.teachers as t]${t.name}[#sep],[/#list]</td>
        <td>研究生</td>
        <td>${book.name}</td>
        <td>${book.isbn!}</td>
        <td>${book.author!}</td>
        <td>${(book.press.name)!}</td>
        <td>${(book.publishedIn?string("yyyy-MM"))!}</td>
        <td>${(book.edition)!}</td>
        <td>研究生</td>
        <td>${book.madeInSchool?string("校外编","校外编")}</td>
        <td>${(book.foreignBookType.name)!}</td>
        <td>${(book.bookType.name)!}</td>
        <td>${(book.disciplineCategory.name)!}</td>
        <td>${(book.bookForm.name)!}</td>
        <td>${(book.press.grade.name)!}</td>
      </tr>
        [/#list]
        [#else]
      <tr>
        <td>${project.school.name}</td>
        <td>${task.semester.year.name}</td>
        <td>${semesterName}</td>
        <td>${task.department.name}</td>
        <td>${task.course.code}</td>
        <td>${task.course.name}</td>
        <td>${task.courseType.name}</td>
        <td>${task.course.defaultCredits}</td>
        <td>[#list task.teachers as t]${t.name}[#sep],[/#list]</td>
        <td>研究生</td>

        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>

        <td></td>

        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
        [/#if]
      [/#list]
    </tbody>
  </table>
  <div style="text-align:center;"><button id="downloadBtn" class="btn btn-sm btn-outline-primary">下载到Excel</button></div>
  <script>
    var fileUrl="${ems_api}/tools/doc/excel";
    var fileName="${project.school.name} ${semester.year.name} 学年度 ${semester.name} 学期 课程教材汇总.xlsx";
    // 下载按钮点击事件
    downloadBtn.addEventListener('click', async () => {
        try {
            // 使用Fetch API获取远程资源
            const response = await fetch(fileUrl,{
                method: 'POST',
                body: document.getElementById("report_table").outerHTML
              }
            );

            // 检查请求是否成功
            if (!response.ok) {
                [#noparse]
                throw new Error(`请求失败: ${response.status}`);
                [/#noparse]
            }

            // 将响应转换为Blob对象
            const blob = await response.blob();

            // 创建下载链接
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = fileName; // 设置保存的文件名

            // 触发下载
            document.body.appendChild(a);
            a.click();

            // 清理资源
            setTimeout(() => {
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            }, 100);
        } catch (error) {
            console.error('下载错误:', error);
        }
    });
  </script>
</div>
[@b.foot/]
