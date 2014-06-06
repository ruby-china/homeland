# coding: utf-8
require 'spec_helper'

describe Topic do
  let(:topic) { FactoryGirl.create(:topic) }
  let(:user) { FactoryGirl.create(:user) }

  it "should no save invalid node_id" do
    FactoryGirl.build(:topic, :node_id => 0).valid?.should_not be_true
  end

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
  
  describe ".update_last_reply" do
    it "should work" do
      t = Factory(:topic)
      old_updated_at = t.updated_at
      r = Factory(:reply, topic: t)
      expect(t.update_last_reply(r)).to be_true
      expect(t.replied_at).to eq r.created_at
      expect(t.last_reply_id).to eq r.id
      expect(t.last_reply_user_id).to eq r.user_id
      expect(t.last_reply_user_login).to eq r.user.login
      expect(t.last_active_mark).not_to be_nil
      expect(t.updated_at).not_to eq old_updated_at
    end
    
    it "should update with nil when have :force" do
      t = Factory(:topic)
      r = Factory(:reply, topic: t)
      t.update_last_reply(nil, force: true)
      expect(t.replied_at).to be_nil
      expect(t.last_reply_id).to be_nil
      expect(t.last_reply_user_id).to be_nil
      expect(t.last_reply_user_login).to be_nil
      expect(t.last_active_mark).not_to be_nil
    end
  end
  
  describe ".update_deleted_last_reply" do
    let(:t) { Factory(:topic) }
    context "when have last Reply and param it that Reply" do
      it "last reply should going to previous Reply" do
        r0 = Factory(:reply, topic: t)
        r1 = Factory(:reply, topic: t)
        expect(t.last_reply_id).to eq r1.id
        t.should_receive(:update_last_reply).with(r0, force: true)
        t.update_deleted_last_reply(r1)
      end
      
      it "last reply will be nil" do
        r = Factory(:reply, topic: t)
        expect(t.update_deleted_last_reply(r)).to be_true
        t.reload
        expect(t.last_reply_id).to be_nil
        expect(t.last_reply_user_login).to be_nil
        expect(t.last_reply_user_id).to be_nil
      end
    end
    
    context "when param is nil" do
      it "should work" do
        expect(t.update_deleted_last_reply(nil)).to be_false
      end
    end
    
    context "when last reply is not equal param" do
      it "should do nothing" do
        r0 = Factory(:reply, topic: t)
        r1 = Factory(:reply, topic: t)
        expect(t.update_deleted_last_reply(r0)).to be_false
        expect(t.last_reply_id).to eq r1.id
      end
    end
  end
  
end
