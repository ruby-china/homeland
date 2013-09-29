# coding: utf-8
require 'spec_helper'

describe Reply do
  let(:user) { FactoryGirl.create(:user) }
  describe "notifications" do
    it "should delete mention notification after destroy" do
      lambda do
        Factory(:reply, :body => "@#{user.login}").destroy
      end.should_not change(user.notifications.unread, :count)
    end

    it "should send topic reply notification to topic author" do
      topic = Factory :topic, :user => user
      lambda do
        Factory :reply, :topic => topic
      end.should change(Mongoid::DelayedDocument.jobs, :size).by(1)

      lambda do
        Factory(:reply, :topic => topic).destroy
      end.should_not change(user.notifications.unread, :count)

      lambda do
        Factory :reply, :topic => topic, :user => user
      end.should_not change(user.notifications.unread, :count)

      # Don't duplicate notifiation with mention
      lambda do
        Factory :reply, :topic => topic, :mentioned_user_ids => [user.id]
      end.should_not change(user.notifications.unread.where(:_type => 'Notification::TopicReply'), :count)
    end

    describe "should send topic reply notification to followers" do
      let(:u1) { FactoryGirl.create(:user) }
      let(:u2) { FactoryGirl.create(:user) }
      let(:t) { FactoryGirl.create(:topic, :follower_ids => [u1.id,u2.id]) }

      # 正常状况
      it "should work" do
        lambda do
          Factory :reply, :topic => t, :user => user
        end.should change(Mongoid::DelayedDocument.jobs, :size).by(1)
      end

      # TODO: 需要更多的测试，测试 @ 并且有关注的时候不会重复通知，回复时候不会通知自己
    end

    describe 'Touch Topic in callback' do
      let(:topic) { Factory :topic, :updated_at => 1.days.ago }
      let(:reply) { Factory :reply, :topic => topic }
      
      it "should update Topic updated_at on Reply updated" do
        old_updated_at = topic.updated_at
        reply.body = "foobar"
        reply.save
        topic.updated_at.should_not == old_updated_at
      end
    
      it 'should update Topic updated_at on Reply deleted' do
        old_updated_at = topic.updated_at
        reply.body = "foobar"
        reply.destroy
        topic.updated_at.should_not == old_updated_at
      end
    end
    

    it "should send_topic_reply_notification work" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic
      lambda do
        Reply.send_topic_reply_notification(reply.id)
      end.should change(user.notifications.unread.where(:_type => 'Notification::TopicReply'), :count).by(1)
    end
  end

  describe "format body" do
    it "should covert body with Markdown on create" do
      r = Factory(:reply, :body => "*foo*")
      r.body_html.should == "<p><em>foo</em></p>"
    end

    it "should covert body on save" do
      r = Factory(:reply, :body => "*foo*")
      old_html = r.body_html
      r.body = "*bar*"
      r.save
      r.body_html.should_not == old_html
    end

    it "should not store body_html when it not changed" do
      r = Factory(:reply, :body => "*foo*")
      r.body = "*fooaa*"
      r.stub!(:body_changed?).and_return(false)
      old_html = r.body_html
      r.save
      r.body_html.should == old_html
    end

    context '#link_mention_user' do
      it 'should add link to mention users' do
        body = '@foo'
        reply = Factory(:reply, :body => body)
        reply.body_html.should == '<p><a href="/foo" class="at_user" title="@foo"><i>@</i>foo</a></p>'
      end
    end
  end

  describe "ban words for Reply body" do
    let(:topic) { Factory(:topic) }
    it "should work" do
      SiteConfig.stub!(:ban_words_on_reply).and_return("mark\n顶")
      topic.replies.create(:body => "顶", :user => user).should have(1).errors_on(:body)
      topic.replies.create(:body => "mark", :user => user).should have(1).errors_on(:body)
      topic.replies.create(:body => " mark ", :user => user).should have(1).errors_on(:body)
      topic.replies.create(:body => "MARK", :user => user).should have(1).errors_on(:body)
      topic.replies.create(:body => "mark1", :user => user).should have(:no).errors_on(:body)
      SiteConfig.stub!(:ban_words_on_reply).and_return("mark\r\n顶")
      topic.replies.create(:body => "mark", :user => user).should have(1).errors_on(:body)
    end

    it "should work when site_config value is nil" do
      SiteConfig.stub!(:ban_words_on_reply).and_return(nil)
      topic.replies.create(:body => "mark", :user => user).should have(:no).errors_on(:body)
    end
  end
end
