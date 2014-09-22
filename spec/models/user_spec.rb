require 'rails_helper'
require "digest/md5"

describe User, :type => :model do
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
      expect(user.topic_read?(topic)).to eq(false)
      user.read_topic(topic)
      expect(user.topic_read?(topic)).to eq(true)
      expect(user2.topic_read?(topic)).to eq(false)
    end

    it "marks the topic as unread when got new reply" do
      topic.replies << reply
      expect(user.topic_read?(topic)).to eq(false)
      user.read_topic(topic)
      expect(user.topic_read?(topic)).to eq(true)
    end

    it "user can soft_delete" do
      user_for_delete1.soft_delete
      user_for_delete1.reload
      expect(user_for_delete1.login).to eq("Guest")
      expect(user_for_delete1.state).to eq(-1)
      user_for_delete2.soft_delete
      user_for_delete1.reload
      expect(user_for_delete1.login).to eq("Guest")
      expect(user_for_delete1.state).to eq(-1)
      expect(user_for_delete1.authorizations).to eq([])
    end
  end
  
  describe '#filter_readed_topics' do
    let(:topics) { FactoryGirl.create_list(:topic, 3) }
    
    it "should work" do
      user.read_topic(topics[1])
      user.read_topic(topics[2])
      expect(user.filter_readed_topics(topics)).to eq([topics[1].id,topics[2].id])
    end
    
    it "should work when params is nil or empty" do
      expect(user.filter_readed_topics(nil)).to eq([])
      expect(user.filter_readed_topics([])).to eq([])
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
      expect(user.location).to eq(new_name)
      expect(user.location_id).to eq(hk_location.id)
      expect(Location.find_by_name(old_name).users_count).to eq(old_location.users_count - 1)
      expect(Location.find_by_name(new_name).users_count).to eq(hk_location.users_count + 1)
    end
  end

  describe "admin?" do
    let (:admin) { Factory :admin }
    it "should know you are an admin" do
      expect(admin).to be_admin
    end

    it "should know normal user is not admin" do
      expect(user).not_to be_admin
    end
  end

  describe "wiki_editor?" do
    let (:admin) { Factory :admin }
    it "should know admin is wiki editor" do
      expect(admin).to be_wiki_editor
    end

    it "should know verified user is wiki editor" do
      user.verified = true
      expect(user).to be_wiki_editor
    end

    it "should know not verified user is not a wiki editor" do
      user.verified = false
      expect(user).not_to be_wiki_editor
    end
  end

  describe "newbie?" do
    it "should true when user created_at less than a week" do
      user.verified = false
      user.created_at = 6.days.ago
      expect(user.newbie?).to be_truthy
    end

    it "should false when more than a week and have 10+ replies" do
      user.verified = false
      user.created_at = 10.days.ago
      user.replies_count = 10
      expect(user.newbie?).to be_falsey
    end

    it "should false when user is verified" do
      user.verified = true
      expect(user.newbie?).to be_falsey
    end
  end

  describe "roles" do
    subject { user }

    context "when is a new user" do
      let(:user) { Factory :user }
      it { is_expected.to have_role(:member) }
    end

    context "when is a blocked user" do
      let(:user) { Factory :blocked_user }
      it { is_expected.not_to have_role(:member) }
    end

    context "when is a deleted user" do
      let(:user) { Factory :blocked_user }
      it { is_expected.not_to have_role(:member) }
    end

    context "when is admin" do
      let(:user) { Factory :admin }
      it { is_expected.to have_role(:admin) }
    end

    context "when is wiki editor" do
      let(:user) { Factory :wiki_editor }
      it { is_expected.to have_role(:wiki_editor) }
    end

    context "when ask for some random role" do
      let(:user) { Factory :user }
      it { is_expected.not_to have_role(:savior_of_the_broken) }
    end
  end

  describe "github url" do
    subject { Factory(:user, :github => 'monkey') }
    let(:expected) { "https://github.com/monkey" }

    context "user name provided correct" do
      describe '#github_url' do
        subject { super().github_url }
        it { is_expected.to eq(expected) }
      end
    end

    context "user name provided as full url" do
      before { allow(subject).to receive(:github).and_return("http://github.com/monkey") }

      describe '#github_url' do
        subject { super().github_url }
        it { is_expected.to eq(expected) }
      end
    end
  end

  describe "private token generate" do
    it "should generate new token" do
      old_token = user.private_token
      user.update_private_token
      expect(user.private_token).not_to eq(old_token)
      user.update_private_token
      expect(user.private_token).not_to eq(old_token)
    end
  end

  describe "favorite topic" do
    it "should favorite a topic" do
      user.favorite_topic(topic.id)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(true)

      expect(user.favorite_topic(nil)).to eq(false)
      expect(user.favorite_topic(topic.id.to_s)).to eq(false)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(true)
    end

    it "should unfavorite a topic" do
      user.unfavorite_topic(topic.id)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(false)
      expect(user.unfavorite_topic(nil)).to eq(false)
      expect(user.unfavorite_topic(topic.id.to_s)).to eq(true)
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
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).to include(user.id)

        user2.like(topic)
        topic.reload
        expect(topic.likes_count).to eq(2)
        expect(topic.liked_user_ids).to include(user2.id)

        user2.unlike(topic)
        topic.reload
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).not_to include(user2.id)
      end

      it "can tell whether or not liked by a user" do
        expect(topic.liked_by_user?(user)).to be_falsey
        user.like(topic)
        expect(topic.liked_by_user?(user)).to be_truthy
      end
    end
  end

  describe "email and email_md5" do
    it "should generate email_md5 when give value to email attribute" do
      old_email = user.email
      user.email = "fooaaaa@gmail.com"
      user.save
      expect(user.email_md5).to eq(Digest::MD5.hexdigest("fooaaaa@gmail.com"))
      expect(user.email).to eq("fooaaaa@gmail.com")
    end

    it "should genrate email_md5 with params" do
      u = User.new
      u.email = "a@gmail.com"
      expect(u.email).to eq("a@gmail.com")
      expect(u.email_md5).to eq(Digest::MD5.hexdigest("a@gmail.com"))
    end
  end
  
  describe '#find_login' do
    let(:user) { Factory :user }
    
    it 'should work' do
      u = User.find_login(user.login)
      expect(u.id).to eq user.id
    end
    
    it 'should ignore case' do
      u = User.find_login(user.login.upcase)
      expect(u.id).to eq user.id
    end
    
    it 'should raise DocumentNotFound error' do
      expect {
        User.find_login(user.login + "1")
      }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
    it 'should railse DocumentNotFound if have bad login' do
      expect {
        User.find_login(user.login + ")")
      }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end
end
