<div class="notprint" id="goto-nav">
  <style>
   .goto-top {
    position: fixed;
    right: 50px;
    bottom: 114px;
    width: 54px;
    height: 54px;
    border:0px;
  }
   .goto-bottom {
    position: fixed;
    right: 50px;
    bottom: 50px;
    width: 54px;
    height: 54px;
    border:0px;
  }
  </style>
  <button class="goto-top" id="gotoTop" title="回到顶部"><i class="fa-solid fa-arrow-up"></i></button>
  <button class="goto-bottom" id="gotoBottom" title="直到底部"><i class="fa-solid fa-arrow-down"></i></button>
  <script>
    function gotoNav(minHeight){
      // 定义点击返回顶部图标后向上滚动的动画
      $("#gotoTop").click(function(){$('html,body').animate({scrollTop:'0px'},'slow');})
      $("#gotoBottom").click(function(){
        var t = $("#goto-nav").offset().top;
        $('html,body').animate({scrollTop:t},'slow');}
      )
      // 获取页面的最小高度，无传入值则默认为600像素
      minHeight? minHeight = minHeight:minHeight = 600;
      // 为窗口的scroll事件绑定处理函数
      $(window).scroll(function(){
        // 获取窗口的滚动条的垂直滚动距离
        var s = $(window).scrollTop();
        // 当窗口的滚动条的垂直距离大于页面的最小高度时，让返回顶部图标渐现，否则渐隐
        if( s > minHeight){
          $("#gotoTop").fadeIn(500);
        }else{
          $("#gotoTop").fadeOut(500);
        };
      });
    };
    gotoNav();
  </script>
</div>
