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
    it "should auto fix on save" do
      topic.title = "Gitlab怎么集成GitlabCI"
      topic.save
      topic.reload
      topic.title.should == "Gitlab 怎么集成 GitlabCI"
    end
  end
  
  describe "#excellent" do
    it "should suggest a topic as excellent" do
      topic.excellent = 1
      topic.save
      Topic.excellent.should include(topic)
    end
  end
end
