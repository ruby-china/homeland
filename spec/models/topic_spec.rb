require 'spec_helper'

describe Topic do
  let(:topic) { FactoryGirl.create(:topic) }
  let(:user) { FactoryGirl.create(:user) }

  it "should set replied_at" do
    # because the Topic index is sort by replied_at,
    # so the new Topic need to set a Time, that it will display in index page
    Factory(:topic).replied_at.should_not be_nil
  end

  it "should not update replied_at on save" do
    replied_at_was = topic.replied_at
    topic.save
    topic.replied_at.should == replied_at_was
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
    topic.replied_at.to_i.should == reply.created_at.to_i
    topic.last_reply_id.should == reply.id
    topic.last_reply_user_id.should == reply.user_id
    topic.last_reply_user_login.should == reply.user.login
  end

  it "should get last reply" do
    topic.last_reply.should == nil
    reply = Factory :reply, :topic => topic, :user => user
    topic.last_reply.should == reply
    reply.destroy
    topic.last_reply.should == nil
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
end
