require 'rails_helper'
require 'digest/md5'

describe User, type: :model do
  before do
    allow_any_instance_of(User).to receive(:update_index).and_return(true)
  end
  let(:topic) { create :topic }
  let(:user)  { create :user }
  let(:user2) { create :user }
  let(:reply) { create :reply }
  let(:user_for_delete1) { create :user }
  let(:user_for_delete2) { create :user }

  describe 'user_type' do
    it { expect(user.user_type).to eq :user }
  end

  describe 'login format' do
    context 'huacnlee' do
      let(:user) { build(:user, login: 'huacnlee') }
      it { expect(user.valid?).to eq true }
    end

    context 'huacnlee-github' do
      let(:user) { build(:user, login: 'huacnlee-github') }
      it { expect(user.valid?).to eq true }
    end

    context 'huacnlee_github' do
      let(:user) { build(:user, login: 'huacnlee_github') }
      it { expect(user.valid?).to eq true }
    end

    context 'huacnlee12' do
      let(:user) { build(:user, login: 'huacnlee12') }
      it { expect(user.valid?).to eq true }
    end

    context '123411' do
      let(:user) { build(:user, login: '123411') }
      it { expect(user.valid?).to eq true }
    end

    context 'zicheng.lhs' do
      let(:user) { build(:user, login: 'zicheng.lhs') }
      it { expect(user.valid?).to eq true }
    end

    context 'll&&^12' do
      let(:user) { build(:user, login: '*ll&&^12') }
      it { expect(user.valid?).to eq false }
    end

    context 'abdddddc$' do
      let(:user) { build(:user, login: 'abdddddc$') }
      it { expect(user.valid?).to eq false }
    end

    context '$abdddddc' do
      let(:user) { build(:user, login: '$abdddddc') }
      it { expect(user.valid?).to eq false }
    end

    context 'aaa*11' do
      let(:user) { build(:user, login: 'aaa*11') }
      it { expect(user.valid?).to eq false }
    end

    describe 'Login allow upcase downcase both' do
      let(:user1) { create(:user, login: 'ReiIs123') }

      it 'should work' do
        expect(user1.login).to eq('ReiIs123')
        expect(User.find_by_login('ReiIs123').id).to eq(user1.id)
        expect(User.find_by_login('reiis123').id).to eq(user1.id)
        expect(User.find_by_login('rEIIs123').id).to eq(user1.id)
      end
    end
  end

  describe '#read_topic?' do
    before do
      allow_any_instance_of(User).to receive(:update_index).and_return(true)
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
      expect(user_for_delete1.state).to eq('deleted')
      user_for_delete2.soft_delete
      user_for_delete1.reload
      expect(user_for_delete1.state).to eq('deleted')
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
      allow(Setting).to receive(:newbie_limit_time).and_return(1.days.to_i)
      user.created_at = 6.hours.ago
      expect(user.newbie?).to be_truthy
    end

    it 'should false when user is verified' do
      user.verified = true
      expect(user.newbie?).to be_falsey
    end

    context 'Unverfied user with 2.days.ago registed.' do
      let(:user) { build(:user, verified: false, created_at: 2.days.ago) }

      it 'should tru with 1 days limit' do
        allow(Setting).to receive(:newbie_limit_time).and_return(1.days.to_i)
        expect(user.newbie?).to be_falsey
      end

      it 'should false with 3 days limit' do
        allow(Setting).to receive(:newbie_limit_time).and_return(3.days.to_i)
        expect(user.newbie?).to be_truthy
      end

      it 'should false with nil limit' do
        allow(Setting).to receive(:newbie_limit_time).and_return(nil)
        expect(user.newbie?).to be_falsey
      end

      it 'should false with 0 limit' do
        allow(Setting).to receive(:newbie_limit_time).and_return('0')
        expect(user.newbie?).to be_falsey
      end
    end
  end

  describe 'roles' do
    subject { user }

    context 'when is a new user' do
      let(:user) { create :user }
      it { expect(user.roles?(:member)).to eq true }
    end

    context 'when is a blocked user' do
      let(:user) { create :blocked_user }
      it { expect(user.roles?(:member)).not_to eq true }
    end

    context 'when is a deleted user' do
      let(:user) { create :blocked_user }
      it { expect(user.roles?(:member)).not_to eq true }
    end

    context 'when is admin' do
      let(:user) { create :admin }
      it { expect(user.roles?(:admin)).to eq true }
    end

    context 'when is wiki editor' do
      let(:user) { create :wiki_editor }
      it { expect(user.roles?(:wiki_editor)).to eq true }
    end

    context 'when ask for some random role' do
      let(:user) { create :user }
      it { expect(user.roles?(:savior_of_the_broken)).not_to eq true }
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

  describe 'website_url' do
    subject { create(:user, website: 'monkey.com') }
    let(:expected) { 'http://monkey.com' }

    context 'website without http://' do
      describe '#website_url' do
        subject { super().website_url }
        it { is_expected.to eq(expected) }
      end
    end

    context 'website with http://' do
      before { allow(subject).to receive(:github).and_return('http://monkey.com') }

      describe '#website_url' do
        subject { super().website_url }
        it { is_expected.to eq(expected) }
      end
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

        expect do
          user.like(reply)
        end.to change(reply, :likes_count).by(1)
      end

      it 'can tell whether or not liked by a user' do
        expect(topic.liked_by_user?(user)).to be_falsey
        user.like(topic)
        expect(topic.liked_by_user?(user)).to be_truthy
        expect(topic.liked_users).to include(user)
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

  describe '#find_by_login!' do
    let(:user) { create :user }

    it 'should work' do
      u = User.find_by_login!(user.login)
      expect(u.id).to eq user.id
      expect(u.login).to eq(user.login)
    end

    it 'should ignore case' do
      u = User.find_by_login!(user.login.upcase)
      expect(u.id).to eq user.id
    end

    it 'should raise DocumentNotFound error' do
      expect do
        User.find_by_login!(user.login + '1')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should railse DocumentNotFound if have bad login' do
      expect do
        User.find_by_login!(user.login + ')')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'Simple prefix user exists' do
      let(:user1) { create :user, login: 'foo' }
      let(:user2) { create :user, login: 'foobar' }
      let(:user2) { create :user, login: 'a2foo' }

      it 'should get right user' do
        u = User.find_by_login!(user1.login)
        expect(u.id).to eq user1.id
        expect(u.login).to eq(user1.login)
      end
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
      expect(user.letter_avatar_url(240)).to include("#{Setting.base_url}/system/letter_avatars/")
    end
  end

  describe '.avatar?' do
    it 'should return false when avatar is nil' do
      u = User.new
      u[:avatar] = nil
      expect(u.avatar?).to eq(false)
    end

    it 'should return true when avatar is not nil' do
      u = User.new
      u[:avatar] = '1234'
      expect(u.avatar?).to eq(true)
    end
  end

  describe '#find_for_database_authentication' do
    let!(:user) { create(:user, login: 'foo', email: 'foobar@gmail.com') }

    it 'should work' do
      expect(User.find_for_database_authentication(login: 'foo').id).to eq user.id
      expect(User.find_for_database_authentication(login: 'foobar@gmail.com').id).to eq user.id
      expect(User.find_for_database_authentication(login: 'not found')).to eq nil
    end

    context 'deleted user' do
      it "should nil" do
        user.update_attributes(state: -1)
        expect(User.find_for_database_authentication(login: 'foo')).to eq nil
      end
    end
  end

  describe '.email_locked?' do
    it { expect(User.new(email: 'foobar@gmail.com').email_locked?).to eq true }
    it { expect(User.new(email: 'foobar@example.com').email_locked?).to eq false }
  end

  describe '.calendar_data' do
    let!(:user) { create(:user) }

    it 'should work' do
      d1 = 1.days.ago
      d2 = 3.days.ago
      d3 = 10.days.ago
      create(:reply, user: user, created_at: d1)
      create_list(:reply, 2, user: user, created_at: d2)
      create_list(:reply, 6, user: user, created_at: d3)

      data = user.calendar_data
      expect(data.keys.count).to eq 3
      expect(data.keys).to include(d1.to_date.to_time.to_i.to_s, d2.to_date.to_time.to_i.to_s, d3.to_date.to_time.to_i.to_s)
      expect(data[d1.to_date.to_time.to_i.to_s]).to eq 1
      expect(data[d2.to_date.to_time.to_i.to_s]).to eq 2
      expect(data[d3.to_date.to_time.to_i.to_s]).to eq 6
    end
  end

  describe '.large_avatar_url' do
    let(:user) { build(:user) }

    context 'avatar is nil' do
      it 'should return letter_avatar_url' do
        user.avatar = nil
        expect(user.large_avatar_url).to include('system/letter_avatars/')
        expect(user.large_avatar_url).to include('192.png')
      end
    end

    context 'avatar is present' do
      it 'should return upload url' do
        user[:avatar] = 'aaa.jpg'
        expect(user.large_avatar_url).to eq user.avatar.url(:lg)
      end
    end
  end

  describe '.team_collection' do
    it 'should work' do
      team_users = create_list(:team_user, 2, user: user)
      teams = team_users.collect(&:team).sort
      expect(user.team_collection.sort).to eq(teams.collect { |t| [t.name, t.id] })
    end

    it 'should get all with admin' do
      ids1 = create_list(:team_user, 2, user: user).collect(&:team_id)
      ids2 = create_list(:team_user, 2, user: user2).collect(&:team_id)
      expect(user).to receive(:admin?).and_return(true)
      expect(user.team_collection.collect { |_, id| id }).to include(*(ids1 + ids2))
    end
  end
end
