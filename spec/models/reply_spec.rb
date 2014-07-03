# coding: utf-8
require 'rails_helper'

describe Reply, :type => :model do
  let(:user) { FactoryGirl.create(:user) }
  describe "notifications" do
    it "should delete mention notification after destroy" do
      expect do
        Factory(:reply, :body => "@#{user.login}").destroy
      end.not_to change(user.notifications.unread, :count)
    end

    it "should send topic reply notification to topic author" do
      topic = Factory :topic, :user => user
      expect do
        Factory :reply, :topic => topic
      end.to change(Mongoid::DelayedDocument.jobs, :size).by(1)

      expect do
        Factory(:reply, :topic => topic).destroy
      end.not_to change(user.notifications.unread, :count)

      expect do
        Factory :reply, :topic => topic, :user => user
      end.not_to change(user.notifications.unread, :count)

      # Don't duplicate notifiation with mention
      expect do
        Factory :reply, :topic => topic, :mentioned_user_ids => [user.id]
      end.not_to change(user.notifications.unread.where(:_type => 'Notification::TopicReply'), :count)
    end

    describe "should send topic reply notification to followers" do
      let(:u1) { FactoryGirl.create(:user) }
      let(:u2) { FactoryGirl.create(:user) }
      let(:t) { FactoryGirl.create(:topic, :follower_ids => [u1.id,u2.id]) }

      # 正常状况
      it "should work" do
        expect do
          Factory :reply, :topic => t, :user => user
        end.to change(Mongoid::DelayedDocument.jobs, :size).by(1)
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
        expect(topic.updated_at).not_to eq(old_updated_at)
      end
    
      it 'should update Topic updated_at on Reply deleted' do
        old_updated_at = topic.updated_at
        reply.body = "foobar"
        reply.destroy
        expect(topic.updated_at).not_to eq(old_updated_at)
      end
    end
    

    it "should send_topic_reply_notification work" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic
      expect do
        Reply.send_topic_reply_notification(reply.id)
      end.to change(user.notifications.unread.where(:_type => 'Notification::TopicReply'), :count).by(1)
    end
  end

  describe "format body" do
    it "should covert body with Markdown on create" do
      r = Factory(:reply, :body => "*foo*")
      expect(r.body_html).to eq("<p><em>foo</em></p>")
    end

    it "should covert body on save" do
      r = Factory(:reply, :body => "*foo*")
      old_html = r.body_html
      r.body = "*bar*"
      r.save
      expect(r.body_html).not_to eq(old_html)
    end

    it "should not store body_html when it not changed" do
      r = Factory(:reply, :body => "*foo*")
      r.body = "*fooaa*"
      allow(r).to receive(:body_changed?).and_return(false)
      old_html = r.body_html
      r.save
      expect(r.body_html).to eq(old_html)
    end

    context '#link_mention_user' do
      it 'should add link to mention users' do
        body = '@foo'
        reply = Factory(:reply, :body => body)
        expect(reply.body_html).to eq('<p><a href="/foo" class="at_user" title="@foo"><i>@</i>foo</a></p>')
      end
    end
  end

  describe "ban words for Reply body" do
    let(:topic) { Factory(:topic) }
    it "should work" do
      allow(SiteConfig).to receive(:ban_words_on_reply).and_return("mark\n顶")
      expect(topic.replies.create(:body => "顶", :user => user).errors[:body].size).to eq(1)
      expect(topic.replies.create(:body => "mark", :user => user).errors[:body].size).to eq(1)
      expect(topic.replies.create(:body => " mark ", :user => user).errors[:body].size).to eq(1)
      expect(topic.replies.create(:body => "MARK", :user => user).errors[:body].size).to eq(1)
      expect(topic.replies.create(:body => "mark1", :user => user).errors[:body].size).to eq(0)
      allow(SiteConfig).to receive(:ban_words_on_reply).and_return("mark\r\n顶")
      expect(topic.replies.create(:body => "mark", :user => user).errors[:body].size).to eq(1)
    end

    it "should work when site_config value is nil" do
      allow(SiteConfig).to receive(:ban_words_on_reply).and_return(nil)
      expect(topic.replies.create(:body => "mark", :user => user).errors[:body].size).to eq(0)
    end
  end
  
  describe "after_destroy" do
    it "should call topic.update_deleted_last_reply" do
      r = Factory(:reply)
      expect(r.topic).to receive(:update_deleted_last_reply).with(r).once
      r.destroy
    end
  end
end
