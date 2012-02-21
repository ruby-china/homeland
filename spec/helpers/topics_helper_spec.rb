# coding: utf-8
require "spec_helper"

describe TopicsHelper do
  describe "format_topic_body" do
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
    
    it "should auto link with Chinese" do
      helper.format_topic_body("靠着中文http://foo.com，").should  == "<p>靠着中文<a href=\"http://foo.com，\" rel=\"nofollow\" target=\"_blank\">http://foo.com，</a></p>"
    end

    it "should render bbcode style image tag" do
      helper.format_topic_body("[img]http://ruby-china.org/logo.png[/img]").should == 
        '<p><img src="http://ruby-china.org/logo.png" alt="Logo"/></p>'
    end

    it "should link mentioned user" do
      user = Factory(:user)
      helper.format_topic_body("hello @#{user.name} @b @a @#{user.name}").should == 
      "<p>hello <a href=\"/users/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a> <a href=\"/users/b\" class=\"at_user\" title=\"@b\"><i>@</i>b</a> <a href=\"/users/a\" class=\"at_user\" title=\"@a\"><i>@</i>a</a> <a href=\"/users/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a></p>"
    end
    
    it "should link mentioned user at first of line" do
      helper.format_topic_body("@huacnlee hello @ruby_box").should == "<p><a href=\"/users/huacnlee\" class=\"at_user\" title=\"@huacnlee\"><i>@</i>huacnlee</a> hello <a href=\"/users/ruby_box\" class=\"at_user\" title=\"@ruby_box\"><i>@</i>ruby_box</a></p>"
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

    it "should wrap break line" do
      helper.format_topic_body("line 1\nline 2").should ==
        "<p>line 1<br/>\nline 2</p>"
    end
    
    it "should support inline code" do
      helper.format_topic_body("This is `Ruby`").should == "<p>This is <code>Ruby</code></p>"
      helper.format_topic_body("This is`Ruby`").should == "<p>This is<code>Ruby</code></p>"
    end

    it "should highlight code block" do
      helper.format_topic_body("```ruby\nclass Hello\nend\n```").should == 
        '<div class="highlight"><pre><span class="k">class</span> <span class="nc">Hello</span>
<span class="k">end</span>
</pre>
</div>' 
    end
    
    it "should highlight code block after the content" do
      helper.format_topic_body("this code:\n```\ngem install rails\n```\n").should ==
        '<p>this code:</p>
<div class="highlight"><pre>gem install rails
</pre>
</div>'
    end
   
    it "should highlight code block without language" do
      helper.format_topic_body("```\ngem install ruby\n```").gsub("\n",'').should == '<div class="highlight"><pre>gem install ruby</pre></div>'
    end
    
    it "should not filter underscore" do
      helper.format_topic_body("ruby_china_image `ruby_china_image`").should == "<p>ruby_china_image <code>ruby_china_image</code></p>"
      helper.format_topic_body("```\nruby_china_image\n```").should == 
        '<div class="highlight"><pre>ruby_china_image
</pre>
</div>'
    end
  end
end
