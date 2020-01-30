# frozen_string_literal: true

require "rails_helper"
require "digest/md5"

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

  describe "user_type" do
    it { assert_equal :user, user.user_type}
  end

  describe "login format" do
    context "huacnlee" do
      let(:user) { build(:user, login: "huacnlee") }
      it { assert_equal true, user.valid?}
    end

    context "huacnlee-github" do
      let(:user) { build(:user, login: "huacnlee-github") }
      it { assert_equal true, user.valid?}
    end

    context "huacnlee_github" do
      let(:user) { build(:user, login: "huacnlee_github") }
      it { assert_equal true, user.valid?}
    end

    context "huacnlee12" do
      let(:user) { build(:user, login: "huacnlee12") }
      it { assert_equal true, user.valid?}
    end

    context "123411" do
      let(:user) { build(:user, login: "123411") }
      it { assert_equal true, user.valid?}
    end

    context "zicheng.lhs" do
      let(:user) { build(:user, login: "zicheng.lhs") }
      it { assert_equal true, user.valid?}
    end

    context "ll&&^12" do
      let(:user) { build(:user, login: "*ll&&^12") }
      it { assert_equal false, user.valid?}
    end

    context "abdddddc$" do
      let(:user) { build(:user, login: "abdddddc$") }
      it { assert_equal false, user.valid?}
    end

    context "$abdddddc" do
      let(:user) { build(:user, login: "$abdddddc") }
      it { assert_equal false, user.valid?}
    end

    context "aaa*11" do
      let(:user) { build(:user, login: "aaa*11") }
      it { assert_equal false, user.valid?}
    end

    describe "Login allow upcase downcase both" do
      let(:user1) { create(:user, login: "ReiIs123") }

      it "should work" do
        assert_equal "ReiIs123", user1.login
        assert_equal user1.id, User.find_by_login("ReiIs123").id
        assert_equal user1.id, User.find_by_login("reiis123").id
        assert_equal user1.id, User.find_by_login("rEIIs123").id
      end
    end
  end

  describe "#read_topic?" do
    before do
      allow_any_instance_of(User).to receive(:update_index).and_return(true)
      Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    end

    it "marks the topic as unread" do
      assert_equal false, user.topic_read?(topic)
      user.read_topic(topic)
      assert_equal true, user.topic_read?(topic)
      assert_equal false, user2.topic_read?(topic)
    end

    it "marks the topic as unread when got new reply" do
      topic.replies << reply
      assert_equal false, user.topic_read?(topic)
      user.read_topic(topic)
      assert_equal true, user.topic_read?(topic)
    end

    it "user can soft_delete" do
      user_for_delete1.soft_delete
      user_for_delete1.reload
      assert_equal "deleted", user_for_delete1.state
      user_for_delete2.soft_delete
      user_for_delete1.reload
      assert_equal "deleted", user_for_delete1.state
      assert_equal [], user_for_delete1.authorizations
    end
  end

  describe "#filter_readed_topics" do
    let(:topics) { create_list(:topic, 3) }

    it "should work" do
      user.read_topic(topics[1])
      user.read_topic(topics[2])
      assert_equal [topics[1].id, topics[2].id], user.filter_readed_topics(topics)
    end

    it "should work when params is nil or empty" do
      assert_equal [], user.filter_readed_topics(nil)
      assert_equal [], user.filter_readed_topics([])
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
      old_location = Location.location_find_by_name(old_name)
      hk_location = create(:location, name: new_name, users_count: 20)
      user.location = new_name
      user.save
      user.reload
      assert_equal new_name, user.location
      assert_equal hk_location.id, user.location_id
      assert_equal old_location.users_count - 1, Location.location_find_by_name(old_name).users_count
      assert_equal hk_location.users_count + 1, Location.location_find_by_name(new_name).users_count
    end
  end

  describe "admin?" do
    let(:admin) { create :admin }
    it "should know you are an admin" do
      expect(admin).to be_admin
    end

    it "should know normal user is not admin" do
      expect(user).not_to be_admin
    end
  end

  describe "wiki_editor?" do
    let(:admin) { create :admin }
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
      allow(Setting).to receive(:newbie_limit_time).and_return(1.days.to_i)
      user.created_at = 6.hours.ago
      assert_equal true, user.newbie?
    end

    it "should false when user is verified" do
      user.verified = true
      assert_equal false, user.newbie?
    end

    context "Unverfied user with 2.days.ago registed." do
      let(:user) { build(:user, verified: false, created_at: 2.days.ago) }

      it "should tru with 1 days limit" do
        allow(Setting).to receive(:newbie_limit_time).and_return(1.days.to_i)
        assert_equal false, user.newbie?
      end

      it "should false with 3 days limit" do
        allow(Setting).to receive(:newbie_limit_time).and_return(3.days.to_i)
        assert_equal true, user.newbie?
      end

      it "should false with nil limit" do
        allow(Setting).to receive(:newbie_limit_time).and_return(nil)
        assert_equal false, user.newbie?
      end

      it "should false with 0 limit" do
        allow(Setting).to receive(:newbie_limit_time).and_return("0")
        assert_equal false, user.newbie?
      end
    end
  end

  describe "roles" do
    subject { user }

    context "when is a new user" do
      let(:user) { create :user }
      it { assert_equal true, user.roles?(:member)}
    end

    context "when is a blocked user" do
      let(:user) { create :blocked_user }
      it { assert_equal false, user.roles?(:member)}
    end

    context "when is a deleted user" do
      let(:user) { create :blocked_user }
      it { assert_equal false, user.roles?(:member)}
    end

    context "when is admin" do
      let(:user) { create :admin }
      it { assert_equal true, user.roles?(:admin)}
    end

    context "when is wiki editor" do
      let(:user) { create :wiki_editor }
      it { assert_equal true, user.roles?(:wiki_editor)}
    end

    context "when ask for some random role" do
      let(:user) { create :user }
      it { assert_equal false, user.roles?(:savior_of_the_broken)}
    end
  end

  describe "github_url" do
    let(:user) { create(:user, github: "monkey") }
    let(:expected) { "https://github.com/monkey" }

    it "user name provided correct" do
      assert_equal expected, user.github_url
    end

    it "user name provided as full url" do
      user.github = "http://github.com/monkey"
      assert_equal expected, user.github_url
    end
  end

  describe "website_url" do
    let(:user) { create(:user, website: "monkey.com") }
    let(:expected) { "http://monkey.com" }

    it "website without http://" do
      assert_equal expected, user.website_url
    end

    it "website with http://" do
      user.github = "http://monkey.com"
      assert_equal expected, user.website_url
    end
  end

  describe "favorite topic" do
    it "should favorite a topic" do
      user.favorite_topic(topic.id)
      assert_equal true, user.favorite_topic_ids.include?(topic.id)
      assert_equal false, user.favorite_topic(nil)
      assert_equal true, user.favorite_topic(topic.id)
      assert_equal true, user.favorite_topic_ids.include?(topic.id)
      assert_equal true, user.favorite_topic?(topic.id)
    end

    it "should unfavorite a topic" do
      user.unfavorite_topic(topic.id)
      assert_equal false, user.favorite_topic_ids.include?(topic.id)
      assert_equal false, user.unfavorite_topic(nil)
      assert_equal true, user.unfavorite_topic(topic)
      assert_equal false, user.favorite_topic?(topic)
    end
  end

  describe "Like" do
    let(:topic) { create :topic }
    let(:user)  { create :user }
    let(:user2) { create :user }

    describe "like topic" do
      it "can like/unlike topic" do
        user.like(topic)
        topic.reload
        assert_equal 1, topic.likes_count
        expect(topic.like_by_user_ids).to include(user.id)

        user2.like(topic)
        topic.reload
        assert_equal 2, topic.likes_count
        expect(topic.like_by_user_ids).to include(user2.id)
        assert_equal true, user.liked?(topic)

        user2.unlike(topic)
        topic.reload
        assert_equal 1, topic.likes_count
        expect(topic.like_by_user_ids).not_to include(user2.id)

        # can't like itself
        topic.user.like(topic)
        topic.reload
        assert_equal 1, topic.likes_count
        expect(topic.like_by_user_ids).not_to include(topic.user_id)

        # can't unlike itself
        topic.user.unlike(topic)
        topic.reload
        assert_equal 1, topic.likes_count
        expect(topic.like_by_user_ids).not_to include(topic.user_id)
      end

      it "can tell whether or not liked by a user" do
        assert_equal false, user.like_topic?(topic)
        user.like(topic)
        topic.reload
        assert_equal true, user.like_topic?(topic)
        expect(topic.like_by_users).to include(user)
      end
    end

    describe "like reply" do
      let(:reply) { create :reply }

      it "should work" do
        user.like(reply)
        assert_equal true, user.like_reply?(reply)
      end

      describe ".like_reply_ids_by_replies" do
        let(:replies) { create_list(:reply, 3) }
        it "should work" do
          user.like(replies[0])
          user.like(replies[2])
          like_ids = user.like_reply_ids_by_replies(replies)
          expect(like_ids).not_to include(replies[1].id)
          expect(like_ids).to include(replies[0].id, replies[2].id)
        end
      end
    end
  end

  describe "email and email_md5" do
    it "should generate email_md5 when give value to email attribute" do
      user.email = "fooaaaa@gmail.com"
      user.save
      assert_equal Digest::MD5.hexdigest("fooaaaa@gmail.com"), user.email_md5
      assert_equal "fooaaaa@gmail.com", user.email
    end

    it "should genrate email_md5 with params" do
      u = User.new
      u.email = "a@gmail.com"
      assert_equal "a@gmail.com", u.email
      assert_equal Digest::MD5.hexdigest("a@gmail.com"), u.email_md5
    end
  end

  describe "#find_by_login!" do
    let(:user) { create :user }

    it "should work" do
      u = User.find_by_login!(user.login)
      assert_equal user.id, u.id
      assert_equal user.login, u.login
    end

    it "should ignore case" do
      u = User.find_by_login!(user.login.upcase)
      assert_equal user.id, u.id
    end

    it "should raise DocumentNotFound error" do
      expect do
        User.find_by_login!(user.login + "1")
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should railse DocumentNotFound if have bad login" do
      expect do
        User.find_by_login!(user.login + ")")
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "Simple prefix user exists" do
      let(:user1) { create :user, login: "foo" }
      let(:user2) { create :user, login: "foobar" }
      let(:user2) { create :user, login: "a2foo" }

      it "should get right user" do
        u = User.find_by_login!(user1.login)
        assert_equal user1.id, u.id
        assert_equal user1.login, u.login
      end
    end
  end

  describe ".block_user" do
    let(:user) { create :user }
    let(:u2) { create :user }
    let(:u3) { create :user }

    it "should work" do
      user.block_user(u2)
      user.block_user(u3)
      expect(user.block_user_ids).to include(u2.id, u3.id)
      expect(u2.block_by_user_ids).to include(user.id)
      expect(u3.block_by_user_ids).to include(user.id)
    end
  end

  describe ".follow_user" do
    let(:u1) { create :user }
    let(:u2) { create :user }
    let(:u3) { create :user }

    it "should work" do
      u1.follow_user(u2)
      u1.follow_user(u3)
      expect(u1.follow_user_ids).to include(u2.id, u3.id)
      assert_equal [u1.id], u2.follow_by_user_ids
      assert_equal [u1.id], u3.follow_by_user_ids

      # Unfollow
      u1.unfollow_user(u3)
      assert_equal [u2.id], u1.follow_user_ids
      u3.reload
      assert_equal [], u3.follow_by_user_ids
    end
  end

  describe ".favorites_count" do
    let(:u1) { create :user }

    it "should work" do
      u1.favorite_topic(1)
      u1.favorite_topic(2)
      assert_equal 2, u1.favorites_count
    end
  end

  describe ".level / .level_name" do
    let(:u1) { create(:user) }

    context "admin" do
      it "should work" do
        allow(u1).to receive(:admin?).and_return(true)
        assert_equal "admin", u1.level
        assert_equal "管理员", u1.level_name
      end
    end

    context "vip" do
      it "should work" do
        allow(u1).to receive(:verified?).and_return(true)
        assert_equal "vip", u1.level
        assert_equal "高级会员", u1.level_name
      end
    end

    context "blocked" do
      it "should work" do
        allow(u1).to receive(:blocked?).and_return(true)
        assert_equal "blocked", u1.level
        assert_equal "禁言用户", u1.level_name
      end
    end

    context "newbie" do
      it "should work" do
        allow(u1).to receive(:newbie?).and_return(true)
        assert_equal "newbie", u1.level
        assert_equal "新手", u1.level_name
      end
    end

    context "normal" do
      it "should work" do
        allow(u1).to receive(:newbie?).and_return(false)
        assert_equal "normal", u1.level
        assert_equal "会员", u1.level_name
      end
    end
  end

  describe ".letter_avatar_url" do
    let(:user) { create(:user) }
    it "should work" do
      expect(user.letter_avatar_url(240)).to include("#{Setting.base_url}/system/letter_avatars/")
    end
  end

  describe ".avatar?" do
    it "should return false when avatar is nil" do
      u = User.new
      u[:avatar] = nil
      assert_equal false, u.avatar?
    end

    it "should return true when avatar is not nil" do
      u = User.new
      u[:avatar] = "1234"
      assert_equal true, u.avatar?
    end
  end

  describe "#find_for_database_authentication" do
    let!(:user) { create(:user, login: "foo", email: "foobar@gmail.com") }

    it "should work" do
      assert_equal user.id, User.find_for_database_authentication(login: "foo").id
      assert_equal user.id, User.find_for_database_authentication(login: "foobar@gmail.com").id
      assert_nil User.find_for_database_authentication(login: "not found")
    end

    context "deleted user" do
      it "should nil" do
        user.update(state: -1)
        assert_nil User.find_for_database_authentication(login: "foo")
      end
    end
  end

  describe ".email_locked?" do
    it { assert_equal true, User.new(email: "foobar@gmail.com").email_locked?}
    it { assert_equal false, User.new(email: "foobar@example.com").email_locked?}
  end

  describe ".calendar_data" do
    let!(:user) { create(:user) }

    it "should work" do
      d1 = "1576339200"
      d2 = "1576944000"
      d3 = "1577116800"
      create(:reply, user: user, created_at: Time.at(d1.to_i + 2.hours))
      create_list(:reply, 2, user: user, created_at: Time.at(d2.to_i + 2.hours))
      create_list(:reply, 6, user: user, created_at: Time.at(d3.to_i + 2.hours))

      data = user.calendar_data
      expect(data.keys.count).to eq 3
      # expect(data.keys).to include(d1, d2, d3)
      # expect(data[d1]).to eq 1
      # expect(data[d2]).to eq 2
      # expect(data[d3]).to eq 6
    end
  end

  describe ".large_avatar_url" do
    let(:user) { build(:user) }

    context "avatar is nil" do
      it "should return letter_avatar_url" do
        user.avatar = nil
        expect(user.large_avatar_url).to include("system/letter_avatars/")
        expect(user.large_avatar_url).to include("192.png")
      end
    end

    context "avatar is present" do
      it "should return upload url" do
        user[:avatar] = "aaa.jpg"
        assert_equal user.avatar.url(:lg), user.large_avatar_url
      end
    end
  end

  describe ".team_options" do
    it "should work" do
      team_users = create_list(:team_user, 2, user: user)
      teams = team_users.collect(&:team).sort
      assert_equal teams.collect { |t| [t.name, t.id] }, user.team_options.sort
    end

    it "should get all with admin" do
      ids1 = create_list(:team_user, 2, user: user).collect(&:team_id)
      ids2 = create_list(:team_user, 2, user: user2).collect(&:team_id)
      expect(user).to receive(:admin?).and_return(true)
      expect(user.team_options.collect { |_, id| id }).to include(*(ids1 + ids2))
    end
  end

  describe "Search methods" do
    let(:u) { create :user, bio: "111", tagline: "222" }
    describe ".indexed_changed?" do
      before(:each) do
        u.reload
      end
      it "login changed work" do
        assert_equal false, u.indexed_changed?
        u.login = u.login + "111"
        u.save
        assert_equal true, u.indexed_changed?
      end

      it "name changed work" do
        assert_equal false, u.indexed_changed?
        u.update(name: u.name + "111")
        assert_equal true, u.indexed_changed?
      end

      it "email changed work" do
        assert_equal false, u.indexed_changed?
        u.update(email: u.email + "111")
        assert_equal true, u.indexed_changed?
      end

      it "bio changed work" do
        assert_equal false, u.indexed_changed?
        u.update(bio: u.bio + "111")
        assert_equal true, u.indexed_changed?
      end

      it "tagline changed work" do
        assert_equal false, u.indexed_changed?
        u.update(tagline: u.tagline + "111")
        assert_equal true, u.indexed_changed?
      end

      it "location changed work" do
        assert_equal false, u.indexed_changed?
        u.update(location: u.location + "111")
        assert_equal true, u.indexed_changed?
      end

      it "other changed work" do
        assert_equal false, u.indexed_changed?
        u.website = "124124124"
        u.github = "124u812"
        u.avatar = "---"
        u.sign_in_count = 190
        u.last_sign_in_at = Time.now
        u.replies_count = u.replies_count + 10
        u.save
        assert_equal false, u.indexed_changed?
      end
    end
  end

  describe "#search" do
    before do
      @rei = create(:user, login: "Rei", replies_count: 5)
      @rain = create(:user, login: "rain")
      @huacnlee = create(:user, login: "huacnlee")
      @hugo = create(:user, login: "Hugo", name: "Rugo", replies_count: 2)
      @hot = create(:user, login: "hot")
    end

    it "should work simple query" do
      res = User.search("r")
      assert_equal @rei.id, res[0].id
      assert_equal @hugo.id, res[1].id
      assert_equal @rain.id, res[2].id

      assert_equal 3, User.search("r").size
      assert_equal 1, User.search("re").size
      assert_equal 3, User.search("h").size
      assert_equal 2, User.search("hu").size
    end

    it "should work with :user option to include following users first" do
      @rei.follow_user(@hugo)
      res = User.search("r", user: @rei, limit: 2)
      assert_equal @hugo.id, res[0].id
      assert_equal @rei.id, res[1].id
      assert_equal 2, res.length
    end
  end
end
