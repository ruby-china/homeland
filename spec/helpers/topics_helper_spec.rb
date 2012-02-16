# coding: utf-8
require "spec_helper"

describe TopicsHelper do
  describe "format_topic_body" do
    it "should bold text " do
      helper.format_topic_body("**bold**").should  == 
        '<p><strong>bold</strong></p>'
    end

    it "should italic text" do
      helper.format_topic_body("*italic*").should  == 
        '<p><em>italic</em></p>'
    end

    it "should strikethrough text" do
      helper.format_topic_body("~~strikethrough~~").should  ==
        '<p><del>strikethrough</del></p>'
    end

    it "should auto link" do
      helper.format_topic_body("this is a link: http://ruby-china.org test").should  == 
        '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>'
    end

   it "should render bbcode style image tag" do
     helper.format_topic_body("[img]http://ruby-china.org/logo.png[/img]").should == 
       '<p><img src="http://ruby-china.org/logo.png" alt="Logo"/></p>'
   end

   it "should link mentioned user" do
     user = Factory(:user)
     helper.format_topic_body("hello @#{user.name}", :mentioned_user_logins => [user.name]).should == 
       "<p>hello <a href=\"/users/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\">@#{user.name}</a></p>"
   end

   it "should link mentioned floor" do
     helper.format_topic_body('#3楼很强大').should ==
       '<p><a href="#reply3" class="at_floor" data-floor="3" onclick="return Topics.hightlightReply(3)">#3楼</a>很强大</p>'
   end

  it "should highlight code block" do
     helper.format_topic_body("```ruby
class Hello
end
```").should == 
      '<div class="highlight"><pre><span class="k">class</span> <span class="nc">Hello</span>
<span class="k">end</span>
</pre>
</div>'
   end
  end
end
