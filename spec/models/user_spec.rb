require 'spec_helper'

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
    end

    it "should not get results when user location not set" do
      User.locations.count == 0
    end

    it "should get results when user location is set" do
      user.location = "hangzhou"
      user2.location = "Hongkong"
      User.locations.count == 2
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

  describe "roles" do
    subject { user }

    context "when is a new user" do
      let(:user) { Factory :user }
      it { should have_role(:member) }
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
end
