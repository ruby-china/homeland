require 'spec_helper'
require "digest/md5"

describe User do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }
  let(:reply) { Factory :reply }
  let(:user_for_delete1) { Factory :user }
  let(:user_for_delete2) { Factory :user }

  describe '#read_topic?' do
    before do
      Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    end

    it 'marks the topic as unread' do
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
      user2.topic_read?(topic).should == false
    end

    it "marks the topic as unread when got new reply" do
      topic.replies << reply
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
    end

    it "user can soft_delete" do
      user_for_delete1.soft_delete
      user_for_delete1.reload
      user_for_delete1.login.should == "Guest"
      user_for_delete1.state.should == -1
      user_for_delete2.soft_delete
      user_for_delete1.reload
      user_for_delete1.login.should == "Guest"
      user_for_delete1.state.should == -1
      user_for_delete1.authorizations.should == []
    end
  end

  describe "location" do
    it "should not get results when user location not set" do
      Location.count == 0
    end

    it "should get results when user location is set" do
      user.location = "hangzhou"
      user2.location = "Hongkong"
      Location.count == 2
    end

    it "should update users_count when user location changed" do
      old_name = user.location
      new_name = "HongKong"
      old_location = Location.find_by_name(old_name)
      hk_location = Factory(:location, :name => new_name, :users_count => 20)
      user.location = new_name
      user.save
      user.reload
      user.location.should == new_name
      user.location_id.should == hk_location.id
      Location.find_by_name(old_name).users_count.should == (old_location.users_count - 1)
      Location.find_by_name(new_name).users_count.should == (hk_location.users_count + 1)
    end
  end

  describe "admin?" do
    let (:admin) { Factory :admin }
    it "should know you are an admin" do
      admin.should be_admin
    end

    it "should know normal user is not admin" do
      user.should_not be_admin
    end
  end

  describe "wiki_editor?" do
    let (:admin) { Factory :admin }
    it "should know admin is wiki editor" do
      admin.should be_wiki_editor
    end

    it "should know verified user is wiki editor" do
      user.verified = true
      user.should be_wiki_editor
    end

    it "should know not verified user is not a wiki editor" do
      user.verified = false
      user.should_not be_wiki_editor
    end
  end

  describe "newbie?" do
    it "should true when user created_at less than a week" do
      user.verified = false
      user.created_at = 6.days.ago
      user.newbie?.should be_true
    end

    it "should false when more than a week and have 10+ replies" do
      user.verified = false
      user.created_at = 10.days.ago
      user.replies_count = 10
      user.newbie?.should be_false
    end

    it "should false when user is verified" do
      user.verified = true
      user.newbie?.should be_false
    end
  end

  describe "roles" do
    subject { user }

    context "when is a new user" do
      let(:user) { Factory :user }
      it { should have_role(:member) }
    end

    context "when is a blocked user" do
      let(:user) { Factory :blocked_user }
      it { should_not have_role(:member) }
    end

    context "when is a deleted user" do
      let(:user) { Factory :blocked_user }
      it { should_not have_role(:member) }
    end

    context "when is admin" do
      let(:user) { Factory :admin }
      it { should have_role(:admin) }
    end

    context "when is wiki editor" do
      let(:user) { Factory :wiki_editor }
      it { should have_role(:wiki_editor) }
    end

    context "when ask for some random role" do
      let(:user) { Factory :user }
      it { should_not have_role(:savior_of_the_broken) }
    end
  end

  describe "github url" do
    subject { Factory(:user, :github => 'monkey') }
    let(:expected) { "https://github.com/monkey" }

    context "user name provided correct" do
      its(:github_url) { should == expected }
    end

    context "user name provided as full url" do
      before { subject.stub!(:github).and_return("http://github.com/monkey") }
      its(:github_url) { should == expected }
    end
  end

  describe "private token generate" do
    it "should generate new token" do
      old_token = user.private_token
      user.update_private_token
      user.private_token.should_not == old_token
      user.update_private_token
      user.private_token.should_not == old_token
    end
  end

  describe "favorite topic" do
    it "should favorite a topic" do
      user.favorite_topic(topic.id)
      user.favorite_topic_ids.include?(topic.id).should == true

      user.favorite_topic(nil).should == false
      user.favorite_topic(topic.id.to_s).should == false
      user.favorite_topic_ids.include?(topic.id).should == true
    end

    it "should unfavorite a topic" do
      user.unfavorite_topic(topic.id)
      user.favorite_topic_ids.include?(topic.id).should == false
      user.unfavorite_topic(nil).should == false
      user.unfavorite_topic(topic.id.to_s).should == true
    end
  end

  describe "Like" do
    let(:topic) { Factory :topic }
    let(:user)  { Factory :user }
    let(:user2)  { Factory :user }

    describe "like topic" do
      it "can like/unlike topic" do
        user.like(topic)
        topic.reload
        topic.likes_count.should == 1
        topic.liked_user_ids.should include(user.id)

        user2.like(topic)
        topic.reload
        topic.likes_count.should == 2
        topic.liked_user_ids.should include(user2.id)

        user2.unlike(topic)
        topic.reload
        topic.likes_count.should == 1
        topic.liked_user_ids.should_not include(user2.id)
      end

      it "can tell whether or not liked by a user" do
        topic.liked_by_user?(user).should be_false
        user.like(topic)
        topic.liked_by_user?(user).should be_true
      end
    end
  end

  describe "email and email_md5" do
    it "should generate email_md5 when give value to email attribute" do
      old_email = user.email
      user.email = "fooaaaa@gmail.com"
      user.save
      user.email_md5.should == Digest::MD5.hexdigest("fooaaaa@gmail.com")
      user.email.should == "fooaaaa@gmail.com"
    end

    it "should genrate email_md5 with params" do
      u = User.new
      u.email = "a@gmail.com"
      u.email.should == "a@gmail.com"
      u.email_md5.should == Digest::MD5.hexdigest("a@gmail.com")
    end
  end
end
