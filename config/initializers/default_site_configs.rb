# coding: utf-8
# 默认配置项
# 如需新增设置项，请在这里初始化默认值，然后到后台修改

# 首页
# SiteConfig.index_html
SiteConfig.save_default("index_html",<<-eos
<div class="box" style="text-align:center;">
  <p><img alt="Big_logo" src="/assets/big_logo.png"></p>
  <p></p>
  <p>Ruby China Group， 致力于构建完善的 Ruby 中文社区。</p>
  <p>功能正在完善中，欢迎 <a href="http://github.com/huacnlee/ruby-china">贡献代码</a> 。</p>
  <p>诚邀有激情的活跃 Ruby 爱好者参与维护社区，联系 <b style="color:#c00;">lgn21st@gmail.com</b></p>
</div>
eos
)

# Wiki 首页 HTML
SiteConfig.save_default("wiki_index_html",<<-eos
<div class="box">
  Wiki Home page. <a href="/wiki/new" class="btn primary">创建新页面</a>
</div>
eos
)

# Footer HTML
SiteConfig.save_default("footer_html",<<-eos
<p class="copyright">
 &copy; Ruby China Group. 
</p>
eos
)