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
  Wiki Home page.
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

# 话题后面的HTML代码
SiteConfig.save_default("after_topic_html",<<-eos
<div class="share_links">
 <a href="https://twitter.com/share" class="twitter-share-button" data-count="none"">Tweet</a>
 <script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>
</div>
eos
)

# 话题正文前面的HTML
SiteConfig.save_default("before_topic_html",<<-eos
eos
)

# 话题列表首页边栏HTML
SiteConfig.save_default("topic_index_sidebar_html",<<-eos
<div class="box">
  <h2>公告</h2>
  <div class="content">
    Hello world.
  </div>
</div>

<div class="box">
  <h2>置顶话题</h2>
  <ul class="content">
    <li><a href="/topics/1">Foo bar</a></li>
  </ul>
</div>
eos
)

# 酷站列表首页头的HTML
SiteConfig.save_default("site_index_html",<<-eos
下面列出了基于 Ruby 语言开发的网站。如果你知道还有不在此列表的，请帮忙补充。
eos
)

# 自定有 HTML head 区域的内容
SiteConfig.save_default("custom_head_html",<<-eos
<link rel="dns-prefetch" href="//assets.youhost.com">
eos
)

# ========================= init Section, Node =========================

# s1 = Section.create(:name => "Ruby")
# Node.create(:name => "Ruby",:summary => "...", :section_id => s1.id)
# Node.create(:name => "Ruby on Rails",:summary => "...", :section_id => s1.id)
# Node.create(:name => "Gem",:summary => "...", :section_id => s1.id)
# s2 = Section.create(:name => "Web Development")
# Node.create(:name => "Python",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Javascript",:summary => "...", :section_id => s2.id)
# Node.create(:name => "CoffeeScript",:summary => "...", :section_id => s2.id)
# Node.create(:name => "HAML",:summary => "...", :section_id => s2.id)
# Node.create(:name => "SASS",:summary => "...", :section_id => s2.id)
# Node.create(:name => "MongoDB",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Redis",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Git",:summary => "...", :section_id => s2.id)
# Node.create(:name => "MySQL",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Hadoop",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Google",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Java",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Tornado",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Linux",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Nginx",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Apache",:summary => "...", :section_id => s2.id)
# Node.create(:name => "Cloud",:summary => "...", :section_id => s2.id)
# s6 = Section.create(:name => "Ruby China")
# Node.create(:name => "公告",:summary => "...", :section_id => s6.id)
# Node.create(:name => "反馈",:summary => "...", :section_id => s6.id)
# Node.create(:name => "开发",:summary => "...", :section_id => s6.id)

# SiteNode.create(:name => "国内商业网站", :sort => 100)
# SiteNode.create(:name => "国外著名网站", :sort => 99)
# SiteNode.create(:name => "Ruby 社区网站", :sort => 98)
# SiteNode.create(:name => "技术博客", :sort => 97)
# SiteNode.create(:name => "Ruby 开源项目", :sort => 96)
# SiteNode.create(:name => "国内企业", :sort => 95)
# SiteNode.create(:name => "其他", :sort => 94)

