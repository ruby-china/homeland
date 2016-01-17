require 'rails_helper'
require 'digest/md5'

describe User, type: :model do
  before do
    User.any_instance.stub(:update_index).and_return(true)
  end
  let(:topic) { create :topic }
  let(:user)  { create :user }
  let(:user2) { create :user }
  let(:reply) { create :reply }
  let(:user_for_delete1) { create :user }
  let(:user_for_delete2) { create :user }

  describe '#read_topic?' do
    before do
      User.any_instance.stub(:update_index).and_return(true)
      Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    end

    it 'marks the topic as unread' do
      expect(user.topic_read?(topic)).to eq(false)
      user.read_topic(topic)
      expect(user.topic_read?(topic)).to eq(true)
      expect(user2.topic_read?(topic)).to eq(false)
    end

    it 'marks the topic as unread when got new reply' do
      topic.replies << reply
      expect(user.topic_read?(topic)).to eq(false)
      user.read_topic(topic)
      expect(user.topic_read?(topic)).to eq(true)
    end

    it 'user can soft_delete' do
      user_for_delete1.soft_delete
      user_for_delete1.reload
      expect(user_for_delete1.state).to eq(-1)
      user_for_delete2.soft_delete
      user_for_delete1.reload
      expect(user_for_delete1.state).to eq(-1)
      expect(user_for_delete1.authorizations).to eq([])
    end
  end

  describe '#filter_readed_topics' do
    let(:topics) { create_list(:topic, 3) }

    it 'should work' do
      user.read_topic(topics[1])
      user.read_topic(topics[2])
      expect(user.filter_readed_topics(topics)).to eq([topics[1].id, topics[2].id])
    end

    it 'should work when params is nil or empty' do
      expect(user.filter_readed_topics(nil)).to eq([])
      expect(user.filter_readed_topics([])).to eq([])
    end
  end

  describe 'location' do
    it 'should not get results when user location not set' do
      Location.count == 0
    end

    it 'should get results when user location is set' do
      user.location = 'hangzhou'
      user2.location = 'Hongkong'
      Location.count == 2
    end

    it 'should update users_count when user location changed' do
      old_name = user.location
      new_name = 'HongKong'
      old_location = Location.location_find_by_name(old_name)
      hk_location = create(:location, name: new_name, users_count: 20)
      user.location = new_name
      user.save
      user.reload
      expect(user.location).to eq(new_name)
      expect(user.location_id).to eq(hk_location.id)
      expect(Location.location_find_by_name(old_name).users_count).to eq(old_location.users_count - 1)
      expect(Location.location_find_by_name(new_name).users_count).to eq(hk_location.users_count + 1)
    end
  end

  describe 'admin?' do
    let(:admin) { create :admin }
    it 'should know you are an admin' do
      expect(admin).to be_admin
    end

    it 'should know normal user is not admin' do
      expect(user).not_to be_admin
    end
  end

  describe 'wiki_editor?' do
    let(:admin) { create :admin }
    it 'should know admin is wiki editor' do
      expect(admin).to be_wiki_editor
    end

    it 'should know verified user is wiki editor' do
      user.verified = true
      expect(user).to be_wiki_editor
    end

    it 'should know not verified user is not a wiki editor' do
      user.verified = false
      expect(user).not_to be_wiki_editor
    end
  end

  describe 'newbie?' do
    it 'should true when user created_at less than a week' do
      user.verified = false
      user.created_at = 6.days.ago
      expect(user.newbie?).to be_truthy
    end

    it 'should false when more than a week and have 10+ replies' do
      user.verified = false
      user.created_at = 10.days.ago
      user.replies_count = 10
      expect(user.newbie?).to be_falsey
    end

    it 'should false when user is verified' do
      user.verified = true
      expect(user.newbie?).to be_falsey
    end
  end

  describe 'roles' do
    subject { user }

    context 'when is a new user' do
      let(:user) { create :user }
      it { is_expected.to have_role(:member) }
    end

    context 'when is a blocked user' do
      let(:user) { create :blocked_user }
      it { is_expected.not_to have_role(:member) }
    end

    context 'when is a deleted user' do
      let(:user) { create :blocked_user }
      it { is_expected.not_to have_role(:member) }
    end

    context 'when is admin' do
      let(:user) { create :admin }
      it { is_expected.to have_role(:admin) }
    end

    context 'when is wiki editor' do
      let(:user) { create :wiki_editor }
      it { is_expected.to have_role(:wiki_editor) }
    end

    context 'when ask for some random role' do
      let(:user) { create :user }
      it { is_expected.not_to have_role(:savior_of_the_broken) }
    end
  end

  describe 'github url' do
    subject { create(:user, github: 'monkey') }
    let(:expected) { 'https://github.com/monkey' }

    context 'user name provided correct' do
      describe '#github_url' do
        subject { super().github_url }
        it { is_expected.to eq(expected) }
      end
    end

    context 'user name provided as full url' do
      before { allow(subject).to receive(:github).and_return('http://github.com/monkey') }

      describe '#github_url' do
        subject { super().github_url }
        it { is_expected.to eq(expected) }
      end
    end
  end

  describe 'private token generate' do
    it 'should generate new token' do
      old_token = user.private_token
      user.update_private_token
      expect(user.private_token).not_to eq(old_token)
      user.update_private_token
      expect(user.private_token).not_to eq(old_token)
    end
  end

  describe 'favorite topic' do
    it 'should favorite a topic' do
      user.favorite_topic(topic.id)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(true)

      expect(user.favorite_topic(nil)).to eq(false)
      expect(user.favorite_topic(topic.id.to_s)).to eq(false)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(true)
      expect(user.favorited_topic?(topic.id)).to eq(true)
    end

    it 'should unfavorite a topic' do
      user.unfavorite_topic(topic.id)
      expect(user.favorite_topic_ids.include?(topic.id)).to eq(false)
      expect(user.unfavorite_topic(nil)).to eq(false)
      expect(user.unfavorite_topic(topic.id.to_s)).to eq(true)
      expect(user.favorited_topic?(topic.id)).to eq(false)
    end
  end

  describe 'Like' do
    let(:topic) { create :topic }
    let(:reply) { create :reply }
    let(:user)  { create :user }
    let(:user2) { create :user }

    describe 'like topic' do
      it 'can like/unlike topic' do
        user.like(topic)
        topic.reload
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).to include(user.id)

        user2.like(topic)
        topic.reload
        expect(topic.likes_count).to eq(2)
        expect(topic.liked_user_ids).to include(user2.id)
        expect(user.liked?(topic)).to eq(true)

        user2.unlike(topic)
        topic.reload
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).not_to include(user2.id)

        # can't like itself
        topic.user.like(topic)
        topic.reload
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).not_to include(topic.user_id)

        # can't unlike itself
        topic.user.unlike(topic)
        topic.reload
        expect(topic.likes_count).to eq(1)
        expect(topic.liked_user_ids).not_to include(topic.user_id)

        expect {
          user.like(reply)
        }.to change(reply, :likes_count).by(1)
      end

      it 'can tell whether or not liked by a user' do
        expect(topic.liked_by_user?(user)).to be_falsey
        user.like(topic)
        expect(topic.liked_by_user?(user)).to be_truthy
      end
    end
  end

  describe 'email and email_md5' do
    it 'should generate email_md5 when give value to email attribute' do
      user.email = 'fooaaaa@gmail.com'
      user.save
      expect(user.email_md5).to eq(Digest::MD5.hexdigest('fooaaaa@gmail.com'))
      expect(user.email).to eq('fooaaaa@gmail.com')
    end

    it 'should genrate email_md5 with params' do
      u = User.new
      u.email = 'a@gmail.com'
      expect(u.email).to eq('a@gmail.com')
      expect(u.email_md5).to eq(Digest::MD5.hexdigest('a@gmail.com'))
    end
  end

  describe '#find_login' do
    let(:user) { create :user }

    it 'should work' do
      u = User.find_login(user.login)
      expect(u.id).to eq user.id
    end

    it 'should ignore case' do
      u = User.find_login(user.login.upcase)
      expect(u.id).to eq user.id
    end

    it 'should raise DocumentNotFound error' do
      expect do
        User.find_login(user.login + '1')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should railse DocumentNotFound if have bad login' do
      expect do
        User.find_login(user.login + ')')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.block_node' do
    let(:user) { create :user }

    it 'should work' do
      user.block_node(1)
      expect(user.blocked_node_ids).to eq [1]
      user.block_node(1)
      expect(user.blocked_node_ids).to eq [1]
      user.block_node(2)
      expect(user.blocked_node_ids).to eq [1, 2]
      user.unblock_node(2)
      expect(user.blocked_node_ids).to eq [1]
    end
  end

  describe '.block_user' do
    let(:user) { create :user }

    it 'should work' do
      user.block_user(1)
      expect(user.blocked_user_ids).to eq [1]
      user.block_user(1)
      expect(user.blocked_user_ids).to eq [1]
      user.block_user(2)
      expect(user.blocked_user_ids).to eq [1, 2]
      user.unblock_user(2)
      expect(user.blocked_user_ids).to eq [1]
    end
  end

  describe '.follow_user' do
    let(:u1) { create :user }
    let(:u2) { create :user }
    let(:u3) { create :user }

    it 'should work' do
      u1.follow_user(u2)
      u1.follow_user(u3)
      expect(u1.following_ids).to eq [u2.id, u3.id]
      expect(u2.follower_ids).to eq [u1.id]
      expect(u3.follower_ids).to eq [u1.id]
      # followed?
      expect(u1.followed?(u2)).to eq true
      expect(u1.followed?(u2.id)).to eq true
      expect(u2.followed?(u1)).to eq false
      # Follow again will not duplicate
      u1.follow_user(u2)
      expect(u1.following_ids).to eq [u2.id, u3.id]
      expect(u2.follower_ids).to eq [u1.id]

      # Unfollow
      u1.unfollow_user(u3)
      expect(u1.following_ids).to eq [u2.id]
      expect(u3.follower_ids).to eq []
    end
  end

  describe '.favorites_count' do
    let(:u1) { create :user, favorite_topic_ids: [1, 2] }

    it 'should work' do
      expect(u1.favorites_count).to eq(2)
    end

  end

  describe '.level / .level_name' do
    let(:u1) { create(:user) }

    context 'admin' do
      it 'should work' do
        allow(u1).to receive(:admin?).and_return(true)
        expect(u1.level).to eq('admin')
        expect(u1.level_name).to eq('管理员')
      end
    end

    context 'vip' do
      it 'should work' do
        allow(u1).to receive(:verified?).and_return(true)
        expect(u1.level).to eq('vip')
        expect(u1.level_name).to eq('高级会员')
      end
    end

    context 'hr' do
      it 'should work' do
        allow(u1).to receive(:hr?).and_return(true)
        expect(u1.level).to eq('hr')
        expect(u1.level_name).to eq('企业 HR')
      end
    end

    context 'blocked' do
      it 'should work' do
        allow(u1).to receive(:blocked?).and_return(true)
        expect(u1.level).to eq('blocked')
        expect(u1.level_name).to eq('禁言用户')
      end
    end

    context 'newbie' do
      it 'should work' do
        allow(u1).to receive(:newbie?).and_return(true)
        expect(u1.level).to eq('newbie')
        expect(u1.level_name).to eq('新手')
      end
    end

    context 'normal' do
      it 'should work' do
        allow(u1).to receive(:newbie?).and_return(false)
        expect(u1.level).to eq('normal')
        expect(u1.level_name).to eq('会员')
      end
    end
  end

  describe '.letter_avatar_url' do
    let(:user) { create(:user) }
    it 'should work' do
      expect(user.letter_avatar_url(240)).to include("#{Setting.protocol}://#{Setting.domain}/system/letter_avatars/")
    end
  end

  describe '.avatar?' do
    it "should return false when avatar is nil" do
      u = User.new
      u[:avatar] = nil
      expect(u.avatar?).to eq(false)
    end

    it "should return true when avatar is not nil" do
      u = User.new
      u[:avatar] = '1234'
      expect(u.avatar?).to eq(true)
    end
  end
end
