[@b.head/]
<div class="container">
<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="brand">
    <img src="${b.static_url('local','/images/logo.png')}" width="50px"/>
     [@b.a href="!index"]${project.school.name}·课程教学大纲上传统计[/@]
    </div>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <a href="#"class="nav-link">${semester.schoolYear}学年${semester.name}学期</a>
      </li>
    </ul>
  </nav>
</header>
  [@bar id="1"  datas=items/]
  <script>
    require(['echarts'], init_1);
  </script>

  [#macro bar id title='' title2='' datas= onclick='' xname='' yname='' interval=0 color=true showSeriesLable=true xrotate=-30
   barMinHeight=20 maxAndMin=true series='' height=300 legend='' trigger='item' alertIdx=0]

  [#if (datas?size gt 0)]
  <div id="${id}" style="height:${height}px;"></div>
  <script>
    function init_${id}(echarts) {
      // 基于准备好的dom，初始化echarts图表
      var myChart = echarts.init(document.getElementById('${id}'));
      var option = {
        color: ['#3398DB'],
        title: {
          text:'${title}',
          left:'center'
          [#if title2 != '']
          , subtext : '${title2}', textAlign:'center'
          [/#if]},
        [#if legend != '']
        legend: {
          data:${legend}
        },
        [/#if]

        xAxis : [
          {
            [#if xname != '']name : '${xname}',[/#if]
            type : 'category',
            start:0,
            axisLabel:{interval:'${interval}', rotate:${xrotate}},
            splitLine:{show: true},
            axisLine:{
              lineStyle:{
                color:'#337ab7',
              }
            },
            data : [[#list datas as d]'${d.entry['name']}'[#sep],[/#list]]
          }
        ],
        yAxis : [
          {
            scale:true,
            axisLine:{
              lineStyle:{color:'#337ab7',}
            },
            [#if yname != '']name : '${yname}',[/#if]
            type : 'value',
            splitLine:{show: true}
          }
        ],
        tooltip : {
          trigger: '${trigger}',
          axisPointer : {            // 坐标轴指示器，坐标轴触发有效
            type : 'shadow'        // 默认为直线，可选为：'line' | 'shadow'
          },
          formatter: function (params) {
            if(params['seriesIndex']==0){
              return params['name']+"<br>已上传课程："+params['value'];
            }else{
              return params['name']+"<br>未上传课程："+params['value'];
            }
          }
        },
        [#assign seriesSize=datas?first.counters?size/]
        series : [
        [#list 0..seriesSize-1 as counter]
          {
            type:"bar",
            barMinHeight: ${barMinHeight},
            barWidth:30,
            stack: 'x',
            smooth:true,
              itemStyle: {
                  normal: {
                    lineStyle:{
                      color:'#E87C25'
                    },
                    [#if counter==0]
                    label: {
                      show: true,
                      position: 'top',
                      formatter: '{c}'
                    },
                    [/#if]
                    color:"[#if counter=0]#50c878[#else]orange[/#if]"
                  }
              },
            data:[[#list datas as d][#if counter==0]${d.counters[1]}[#else]${d.counters[0]-d.counters[1]}[/#if][#sep],[/#list]]
          }[#if counter_has_next],[/#if]
        [/#list]
        ]
      };
      // 为echarts对象加载数据
      myChart.setOption(option);
    }
  </script>
  [#else]
  <div style="padding:100px; font-size:20px; text-align:center">暂无数据</div>
  [/#if]
  [/#macro]
  <table class="table table-sm">
    <thead>
      <tr>
        <td>序号</td>
        <td>院系</td>
        <td>总数</td>
        <td>已上传</td>
        <td>完成度</td>
      </tr>
    </thead>
    <tbody>
    [#list items as item]
      <tr>
        <td>${item_index+1}</td>
        <td>${item.entry['name']}</td>
        <td>${item.counters[0]}</td>
        <td>${item.counters[1]}</td>
        <td>[#if item.counters[0]==0]--[#else]${(item.counters[1]*1.0/item.counters[0])?string.percent}[/#if]
      </tr>
    [/#list]
    </tbody>
  </table>
</div>
[@b.foot/]
