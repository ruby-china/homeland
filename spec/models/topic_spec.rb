# coding: utf-8
require 'spec_helper'

describe Topic do
  let(:topic) { FactoryGirl.create(:topic) }
  let(:user) { FactoryGirl.create(:user) }

  it "should set last_active_mark on created" do
    # because the Topic index is sort by replied_at,
    # so the new Topic need to set a Time, that it will display in index page
    Factory(:topic).last_active_mark.should_not be_nil
  end

  it "should not update last_active_mark on save" do
    last_active_mark_was = topic.last_active_mark
    topic.save
    topic.last_active_mark.should == last_active_mark_was
  end

  it "should get node name" do
    node = Factory :node
    Factory(:topic, :node => node).node_name.should == node.name
  end

  describe "#push_follower, #pull_follower" do
    let(:t) { FactoryGirl.create(:topic, :user_id => 0) }
    it "should push" do
      t.push_follower user.id
      t.follower_ids.include?(user.id).should be_true
    end

    it "should pull" do
      t.pull_follower user.id
      t.follower_ids.include?(user.id).should_not be_true
    end

    it "should not push when current_user is topic creater" do
      t.stub!(:user_id).and_return(user.id)
      t.push_follower(user.id).should == false
      t.follower_ids.include?(user.id).should_not be_true
    end
  end

  it "should update after reply" do
    reply = Factory :reply, :topic => topic, :user => user
    topic.last_active_mark.should == reply.created_at.to_i
    topic.replied_at.to_i.should == reply.created_at.to_i
    topic.last_reply_id.should == reply.id
    topic.last_reply_user_id.should == reply.user_id
    topic.last_reply_user_login.should == reply.user.login
  end
  
  it "should update after reply without last_active_mark when the topic is created at month ago" do
    topic.stub!(:created_at).and_return(1.month.ago)
    topic.stub!(:last_active_mark).and_return(1)
    reply = Factory :reply, :topic => topic, :user => user
    topic.last_active_mark.should_not == reply.created_at.to_i
    topic.last_reply_user_id.should == reply.user_id
    topic.last_reply_user_login.should == reply.user.login
  end

  it "should covert body with Markdown on create" do
    t = Factory(:topic, :body => "*foo*")
    t.body_html.should == "<p><em>foo</em></p>"
  end


  it "should covert body on save" do
    t = Factory(:topic, :body => "*foo*")
    old_html = t.body_html
    t.body = "*bar*"
    t.save
    t.body_html.should_not == old_html
  end

  it "should not store body_html when it not changed" do
    t = Factory(:topic, :body => "*foo*")
    t.body = "*fooaa*"
    t.stub!(:body_changed?).and_return(false)
    old_html = t.body_html
    t.save
    t.body_html.should == old_html
  end

  it "should log deleted user name when use destroy_by" do
    t = Factory(:topic)
    t.destroy_by(user)
    t.who_deleted.should == user.login
    t.deleted_at.should_not == nil
    t1 = Factory(:topic)
    t1.destroy_by(nil).should == false
  end
  
  describe "#auto_space_with_en_zh" do
    it "should work with simple" do
      Topic.auto_space_with_en_zh("部署到heroku有问题网页不能显示").should == "部署到 heroku 有问题网页不能显示"
    end
    
    it "should with () or []" do
      Topic.auto_space_with_en_zh("[北京]美企聘site/web大型应用开发高手-Ruby（Java/PHP/Python也可）").should == "[北京]美企聘 site/web 大型应用开发高手-Ruby（Java/PHP/Python 也可）"      
      Topic.auto_space_with_en_zh("[成都](团800)招聘Rails工程师").should == "[成都](团 800)招聘 Rails 工程师"
    end
    
    it "should with . !" do
      Topic.auto_space_with_en_zh("Teahour.fm第18期发布").should == "Teahour.fm 第 18 期发布"
      Topic.auto_space_with_en_zh("Yes!升级到了Rails 4").should == "Yes! 升级到了 Rails 4"
      Topic.auto_space_with_en_zh("delete!方法是做什么的").should == "delete! 方法是做什么的"
      Topic.auto_space_with_en_zh("到了!升级到了Rails 4").should == "到了! 升级到了 Rails 4"
    end
    
    it "should with URL" do
      Topic.auto_space_with_en_zh("http://sourceforge.net/解禁了") == "http://sourceforge.net/ 解禁了"
    end
    
    it "should with #" do
      Topic.auto_space_with_en_zh("个人信息显示公开记事本,记事本显示阅读次数#149").should == "个人信息显示公开记事本,记事本显示阅读次数 #149"      
    end
    
    it "should with @" do
      Topic.auto_space_with_en_zh("里面用@foo符号的话后面的变量名会被替换成userN").should == "里面用 @foo 符号的话后面的变量名会被替换成 userN"
    end
    
    it 'should with \ /' do
      Topic.auto_space_with_en_zh("我/解禁了") == "我 / 解禁了"
      Topic.auto_space_with_en_zh("WWDC上讲到的Objective C/LLVM改进").should == "WWDC 上讲到的 Objective C/LLVM 改进"
    end

    it "should with number" do
      Topic.auto_space_with_en_zh("在Ubuntu11.10 64位系统安装newrelic出错").should == "在 Ubuntu11.10 64 位系统安装 newrelic 出错"
      Topic.auto_space_with_en_zh("升级了10.9 附遇到的bug").should == "升级了 10.9 附遇到的 bug"
      Topic.auto_space_with_en_zh("喜欢暗黑2却对D3不满意的可以看看这个。。").should == "喜欢暗黑 2 却对 D3 不满意的可以看看这个。。"
      Topic.auto_space_with_en_zh("在做ROR 3.2 Tutorial第Chapter 9.4.2遇到一个问题求助！").should == "在做 ROR 3.2 Tutorial 第 Chapter 9.4.2 遇到一个问题求助！"
    end
    
    it "should with other cases" do
      Topic.auto_space_with_en_zh("创建一篇article，但是却爆了ActionDispatch::Cookies::CookieOverflow的异常").should == "创建一篇 article，但是却爆了 ActionDispatch::Cookies::CookieOverflow 的异常"
      Topic.auto_space_with_en_zh("Mac安装软件新方法：Homebrew-cask").should == "Mac 安装软件新方法：Homebrew-cask"
      Topic.auto_space_with_en_zh("Mac安装软件新方法: Homebrew-cask").should == "Mac 安装软件新方法: Homebrew-cask"
      Topic.auto_space_with_en_zh("Gitlab怎么集成GitlabCI.").should == "Gitlab 怎么集成 GitlabCI."
    end
    
    it "should with 年月日" do
      Topic.auto_space_with_en_zh("5天的活动").should == "5 天的活动"
      Topic.auto_space_with_en_zh("我10岁的时候").should == "我 10 岁的时候"
      Topic.auto_space_with_en_zh("于3月10日开始").should == "于 3月10日开始"
      Topic.auto_space_with_en_zh("2013年3月10日-Ruby Saturday活动召集").should == "2013年3月10日 - Ruby Saturday 活动召集"
    end
    
    it "should auto fix on save" do
      topic.title = "Gitlab怎么集成GitlabCI"
      topic.save
      topic.reload
      topic.title.should == "Gitlab 怎么集成 GitlabCI"
    end
  end
end
