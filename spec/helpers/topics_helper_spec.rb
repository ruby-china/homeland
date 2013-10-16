# coding: utf-8
require "spec_helper"

describe TopicsHelper do
  describe "format_topic_body" do
    it "should right with Chinese neer URL" do
      # TODO: 这行是由于 Redcarpet 的 auto_link 方法转换连起来的会有编码错误
      #  @huacnlee提醒说在某些环境下面，下面测试会Pass。所以有可能在你的测试环境会失败。
      helper.format_topic_body("此版本并非线上的http://yavaeye.com的源码.").should ==
        '<p>此版本并非线上的<a href="http://yavaeye.com" rel="nofollow" target="_blank">http://yavaeye.com</a>的源码.</p>'
      helper.format_topic_body("http://foo.com,的???").should ==
        '<p><a href="http://foo.com," rel="nofollow" target="_blank">http://foo.com,</a>的???</p>'
      helper.format_topic_body("http://foo.com，的???").should ==
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>，的???</p>'
      helper.format_topic_body("http://foo.com。的???").should ==
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>。的???</p>'
      helper.format_topic_body("http://foo.com；的???").should ==
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>；的???</p>'
    end

    it "should match complex urls" do
      helper.format_topic_body("http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD").should ==
        '<p><a href="http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD" rel="nofollow" target="_blank">http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD</a></p>'
      helper.format_topic_body("http://ruby-china.org/self_posts/11?datas=20,33|100&format=.jpg").should ==
        '<p><a href="http://ruby-china.org/self_posts/11?datas=20,33%7C100&amp;format=.jpg" rel="nofollow" target="_blank">http://ruby-china.org/self_posts/11?datas=20,33|100&amp;format=.jpg</a></p>'
      helper.format_topic_body("https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J").should ==
        '<p><a href="https://g.l/b/?fromgroups#!searchin/gitlabhq/self%2420regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J" rel="nofollow" target="_blank">https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J</a></p>'
    end

    it "should bold text " do
      helper.format_topic_body("**bold**").should == '<p><strong>bold</strong></p>'
    end

    it "should italic text" do
      helper.format_topic_body("*italic*").should == '<p><em>italic</em></p>'
    end

    it "should strikethrough text" do
      helper.format_topic_body("~~strikethrough~~").should == '<p><del>strikethrough</del></p>'
    end

    it "should auto link" do
      helper.format_topic_body("this is a link: http://ruby-china.org test").should  ==
        '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>'
    end
    
    it "should auto link" do
      helper.format_topic_body("http://ruby-china.org/~users").should  ==
        '<p><a href="http://ruby-china.org/~users" rel="nofollow" target="_blank">http://ruby-china.org/~users</a></p>'
    end

    it "should auto link with Chinese" do
      helper.format_topic_body("靠着中文http://foo.com，").should  ==
        "<p>靠着中文<a href=\"http://foo.com\" rel=\"nofollow\" target=\"_blank\">http://foo.com</a>，</p>"
    end

    it "should render bbcode style image tag" do
      helper.format_topic_body("[img]http://ruby-china.org/logo.png[/img]").should ==
        '<p><img src="http://ruby-china.org/logo.png" alt="Logo"></p>'
    end

    it "should link mentioned user" do
      user = Factory(:user)
      helper.format_topic_body("hello @#{user.name} @b @a @#{user.name}").should ==
      "<p>hello <a href=\"/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a> <a href=\"/b\" class=\"at_user\" title=\"@b\"><i>@</i>b</a> <a href=\"/a\" class=\"at_user\" title=\"@a\"><i>@</i>a</a> <a href=\"/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a></p>"
    end

    it "should link mentioned user at first of line" do
      helper.format_topic_body("@huacnlee hello @ruby_box").should == "<p><a href=\"/huacnlee\" class=\"at_user\" title=\"@huacnlee\"><i>@</i>huacnlee</a> hello <a href=\"/ruby_box\" class=\"at_user\" title=\"@ruby_box\"><i>@</i>ruby_box</a></p>"
    end

    it "should not allow H1-H6 to h4" do
      ['# ruby','## ruby','### ruby','#### ruby',"ruby\n----","ruby\n===="].each do |str|
        helper.format_topic_body(str).should == "<h4>ruby</h4>"
      end
    end

    it "should support ul,ol" do
       helper.format_topic_body("* Ruby on Rails\n* Sinatra").gsub("\n","").should == "<ul><li>Ruby on Rails</li><li>Sinatra</li></ul>"
       helper.format_topic_body("1. Ruby on Rails\n2. Sinatra").gsub("\n","").should == "<ol><li>Ruby on Rails</li><li>Sinatra</li></ol>"
    end

    it "should email neer Chinese chars can work" do
      # 次处要保留 在某些场景下面 email 后面紧接中文逗号会出现编码异常，而导致错误
      helper.format_topic_body('可以给我邮件 monster@gmail.com，').should == "<p>可以给我邮件 monster@gmail.com，</p>"
    end

    it "should link mentioned floor" do
      helper.format_topic_body('#3楼很强大').should ==
        '<p><a href="#reply3" class="at_floor" data-floor="3">#3楼</a>很强大</p>'
    end

    it "should right encoding with #1楼 @ichord 刚刚发布，有点问题" do
      helper.format_topic_body("#1楼 @ichord 刚刚发布，有点问题").should ==
      %(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="at_user" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)
    end

    it "should wrap break line" do
      helper.format_topic_body("line 1\nline 2").should ==
        "<p>line 1<br>\nline 2</p>"
    end

    it "should support inline code" do
      helper.format_topic_body("This is `Ruby`").should == "<p>This is <code>Ruby</code></p>"
      helper.format_topic_body("This is`Ruby`").should == "<p>This is<code>Ruby</code></p>"
    end

    it "should highlight code block" do
      helper.format_topic_body("```ruby\nclass Hello\n\nend\n```").should ==
        %(<pre class=\"highlight ruby\"><span class=\"k\">class</span> <span class=\"nc\">Hello</span>\n\n<span class=\"k\">end</span>\n</pre>)
    end

    it "should be able to identigy Ruby or RUBY as ruby language" do
      ['Ruby', 'RUBY'].each do |lang|
        helper.format_topic_body("```#{lang}\nclass Hello\nend\n```").should ==
          %(<pre class=\"highlight ruby\"><span class=\"k\">class</span> <span class=\"nc\">Hello</span>\n<span class=\"k\">end</span>\n</pre>)
      end
    end

    it "should highlight code block after the content" do
      helper.format_topic_body("this code:\n```\ngem install rails\n```\n").should ==
        %(<p>this code:</p>\n<pre class=\"highlight plaintext\">gem install rails\n</pre>)
    end

    it "should highlight code block without language" do
      helper.format_topic_body("```\ngem install ruby\n```").gsub("\n",'').should ==
        %(<pre class=\"highlight plaintext\">gem install ruby</pre>)
    end

    it "should not filter underscore" do
      helper.format_topic_body("ruby_china_image `ruby_china_image`").should == "<p>ruby_china_image <code>ruby_china_image</code></p>"
      helper.format_topic_body("```\nruby_china_image\n```").should ==
        %(<pre class=\"highlight plaintext\">ruby_china_image\n</pre>)
    end
  end

  describe "topic_favorite_tag" do
    let(:user) { Factory :user }
    let(:topic) { Factory :topic }

    it "should run with nil param" do
      helper.stub(:current_user).and_return(nil)
      helper.topic_favorite_tag(nil).should == ""
    end

    it "should result when logined user did not favorite topic" do
      user.stub(:favorite_topic_ids).and_return([])
      helper.stub(:current_user).and_return(user)
      helper.topic_favorite_tag(topic).should == %(<a class="icon small_bookmark" data-id="#{topic.id}" href="#" onclick="return Topics.favorite(this);" rel="twipsy" title="收藏"></a>)
    end

    it "should result when logined user favorited topic" do
      user.stub(:favorite_topic_ids).and_return([topic.id])
      helper.stub(:current_user).and_return(user)
      helper.topic_favorite_tag(topic).should == %(<a class="icon small_bookmarked" data-id="#{topic.id}" href="#" onclick="return Topics.favorite(this);" rel="twipsy" title="取消收藏"></a>)
    end

    it "should result blank when unlogin user" do
      helper.stub(:current_user).and_return(nil)
      helper.topic_favorite_tag(topic).should == ""
    end
  end
end
