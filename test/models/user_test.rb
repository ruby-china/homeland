# frozen_string_literal: true

require "test_helper"
require "digest/md5"

class UserTest < ActiveSupport::TestCase
  setup do
    User.any_instance.stubs(:update_index).returns(true)
    @user = nil
  end

  def user; @user ||= create(:user); end

  test "user_type" do
    assert_equal :user, user.user_type
  end

  def assert_valid_login(valid, logins)
    user = build(:user, login: login)
    assert_equal valid, user.valid?
  end

  test "login format" do
    logins = %w[huacnlee huacnlee_github huacnlee12 123411 zicheng.lhs]
    logins.each do |login|
      user = build(:user, login: login)
      assert_equal true, user.valid?
    end

    invalid_logins = %w[*ll&&^12 abdddddc$ $abdddddc aaa*11 ]
    invalid_logins.each do |login|
      user = build(:user, login: login)
      assert_equal false, user.valid?
    end
  end

  test "find_by_login allow upcase downcase both" do
    user = create(:user, login: "ReiIs123")

    assert_equal "ReiIs123", user.login
    assert_equal user.id, User.find_by_login("ReiIs123").id
    assert_equal user.id, User.find_by_login("reiis123").id
    assert_equal user.id, User.find_by_login("rEIIs123").id
  end

  test "#read_topic?  marks the topic as unread" do
    user2 = create(:user)
    topic = create(:topic)

    User.any_instance.stubs(:update_index).returns(true)
    Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    assert_equal false, user.topic_read?(topic)
    user.read_topic(topic)
    assert_equal true, user.topic_read?(topic)
    assert_equal false, user2.topic_read?(topic)
  end

  test "#read_topic? marks the topic as unread when got new reply" do
    topic = create(:topic)

    reply = create(:reply)
    User.any_instance.stubs(:update_index).returns(true)
    Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    topic.replies << reply
    assert_equal false, user.topic_read?(topic)
    user.read_topic(topic)
    assert_equal true, user.topic_read?(topic)
  end

  test "#filter_readed_topics" do
    topics = create_list(:topic, 3)

    user.read_topic(topics[1])
    user.read_topic(topics[2])
    assert_equal [topics[1].id, topics[2].id], user.filter_readed_topics(topics)

    # should work when params is nil or empty
    assert_equal [], user.filter_readed_topics(nil)
    assert_equal [], user.filter_readed_topics([])
  end

  test "location" do
    Location.count == 0

    # should get results when user location is set
    user.location = "hangzhou"
    user.reload
    create(:user, location: "Hongkong")
    Location.count == 2

    # should update users_count when user location changed
    old_name = user.location
    new_name = "Chengdu"
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

  test "admin?" do
    admin = User.new(state: :admin)
    assert_equal true, admin.admin?
    assert_equal false, user.admin?

    Setting.stub(:admin_emails, %w[foobar@gmail.com]) do
      user = User.new(email: "foobar@gmail.com", state: :member)
      assert true, user.admin?
    end
  end

  test "wiki_editor?" do
    admin = User.new(state: :admin)
    assert_equal true, admin.wiki_editor?
    assert_equal false, user.wiki_editor?

    user = User.new(state: :vip)
    assert_equal true, user.wiki_editor?

    user = User.new
    assert_equal false, user.wiki_editor?
  end

  test "newbie?" do
    # should true when user created_at less than a week
    Setting.stubs(:newbie_limit_time).returns(1.days.to_i)
    user.created_at = 6.hours.ago
    assert_equal true, user.newbie?

    # should false when user is vip
    user.state = :vip
    assert_equal false, user.newbie?

    # should false when user is hr
    user.state = :hr
    assert_equal false, user.newbie?

    # Unverfied user with 2.days.ago registed.
    user = User.new(created_at: 2.days.ago)

    Setting.stubs(:newbie_limit_time).returns(1.days.to_i)
    assert_equal false, user.newbie?

    Setting.stubs(:newbie_limit_time).returns(3.days.to_i)
    assert_equal true, user.newbie?

    Setting.stubs(:newbie_limit_time).returns(nil)
    assert_equal false, user.newbie?

    Setting.stubs(:newbie_limit_time).returns(0)
    assert_equal false, user.newbie?
  end

  test "roles" do
    # when is a new user
    assert_equal true, user.roles?(:member)

    # when is a blocked user
    user = User.new(state: :blocked)
    assert_equal false, user.roles?(:member)

    # when is a deleted user" do
    user = User.new(state: :deleted)
    assert_equal false, user.roles?(:member)

    # when is admin
    user = User.new(state: :admin)
    assert_equal true, user.roles?(:admin)

    # when is wiki editor
    user = User.new(state: :vip)
    assert_equal true, user.roles?(:wiki_editor)

    # when ask for some random role
    user = create :user
    assert_equal false, user.roles?(:savior_of_the_broken)
  end

  test "github_url" do
    user = User.new(github: "monkey")

    expected = "https://github.com/monkey"
    assert_equal expected, user.github_url

    user.github = "http://github.com/monkey"
    assert_equal expected, user.github_url
  end

  test "website_url" do
    user = User.new(website: "monkey.com")
    expected = "http://monkey.com"

    # website without http://
    assert_equal expected, user.website_url

    # website with http://
    user.github = "http://monkey.com"
    assert_equal expected, user.website_url
  end

  test "favorite topic" do
    topic = create(:topic)

    user.favorite_topic(topic.id)
    assert_equal true, user.favorite_topic_ids.include?(topic.id)
    assert_equal false, user.favorite_topic(nil)
    assert_equal true, user.favorite_topic(topic.id)
    assert_equal true, user.favorite_topic_ids.include?(topic.id)
    assert_equal true, user.favorite_topic?(topic.id)

    user.unfavorite_topic(topic.id)
    assert_equal false, user.favorite_topic_ids.include?(topic.id)
    assert_equal false, user.unfavorite_topic(nil)
    assert_equal true, user.unfavorite_topic(topic)
    assert_equal false, user.favorite_topic?(topic)
  end

  test "Like" do
    topic = create(:topic)
    user2 = create(:user)

    # can like/unlike topic
    user.like(topic)
    topic.reload
    assert_equal 1, topic.likes_count
    assert_includes topic.like_by_user_ids, user.id

    user2.like(topic)
    topic.reload
    assert_equal 2, topic.likes_count
    assert_includes topic.like_by_user_ids, user2.id
    assert_equal true, user.liked?(topic)

    user2.unlike(topic)
    topic.reload
    assert_equal 1, topic.likes_count
    assert_not_includes topic.like_by_user_ids, user2.id

    # can't like itself
    topic.user.like(topic)
    topic.reload
    assert_equal 1, topic.likes_count
    assert_not_includes topic.like_by_user_ids, topic.user_id

    # can't unlike itself
    topic.user.unlike(topic)
    topic.reload
    assert_equal 1, topic.likes_count
    assert_not_includes topic.like_by_user_ids, topic.user_id
  end

  test "like can tell whether or not liked by a user" do
    topic = create(:topic)
    user = create(:user)

    assert_equal false, user.like_topic?(topic)
    user.like(topic)
    topic.reload
    assert_equal true, user.like_topic?(topic)
    assert_includes topic.like_by_users, user
  end

  test "like reply" do
    topic = create(:topic)
    reply = create(:reply)

    user.like(reply)
    assert_equal true, user.like_reply?(reply)

    replies = create_list(:reply, 3)

    user.like(replies[0])
    user.like(replies[2])
    like_ids = user.like_reply_ids_by_replies(replies)
    assert_not_includes like_ids, replies[1].id
    assert_includes_all like_ids, replies[0].id, replies[2].id
  end

  test "email and email_md5" do
    # should generate email_md5 when give value to email attribute
    user.email = "fooaaaa@gmail.com"
    user.save
    assert_equal Digest::MD5.hexdigest("fooaaaa@gmail.com"), user.email_md5
    assert_equal "fooaaaa@gmail.com", user.email

    # should genrate email_md5 with params
    u = User.new
    u.email = "a@gmail.com"
    assert_equal "a@gmail.com", u.email
    assert_equal Digest::MD5.hexdigest("a@gmail.com"), u.email_md5
  end

  test "#find_by_login!" do

    u = User.find_by_login!(user.login)
    assert_equal user.id, u.id
    assert_equal user.login, u.login


    # should ignore case
    u = User.find_by_login!(user.login.upcase)
    assert_equal user.id, u.id

    # should raise DocumentNotFound error
    assert_raise ActiveRecord::RecordNotFound do
      User.find_by_login!(user.login + "1")
    end

    # should railse DocumentNotFound if have bad login" do
    assert_raise ActiveRecord::RecordNotFound do
      User.find_by_login!(user.login + ")")
    end
  end

  test "find_by_login! Simple prefix user exists" do
    user1 = create :user, login: "foo"
    user2 = create :user, login: "foobar"
    user2 = create :user, login: "a2foo"

    u = User.find_by_login!(user1.login)
    assert_equal user1.id, u.id
    assert_equal user1.login, u.login
  end

  test ".block_user" do
    user = create :user
    u2 = create :user
    u3 = create :user

    user.block_user(u2)
    user.block_user(u3)
    assert_includes_all user.block_user_ids, u2.id, u3.id
    assert_includes_all u2.block_by_user_ids, user.id
    assert_includes_all u3.block_by_user_ids, user.id
  end

  test ".follow_user" do
    u1 = create :user
    u2 = create :user
    u3 = create :user

    u1.follow_user(u2)
    u1.follow_user(u3)
    assert_includes_all u1.follow_user_ids, u2.id, u3.id
    assert_equal [u1.id], u2.follow_by_user_ids
    assert_equal [u1.id], u3.follow_by_user_ids

    # Unfollow
    u1.unfollow_user(u3)
    assert_equal [u2.id], u1.follow_user_ids
    u3.reload
    assert_equal [], u3.follow_by_user_ids
  end

  test ".favorites_count" do
    u1 = create :user

    u1.favorite_topic(1)
    u1.favorite_topic(2)
    assert_equal 2, u1.favorites_count
  end

  test ".level / .level_name" do
    u1 = User.new(state: :member)
    assert_equal "member", u1.level
    assert_equal "Member", u1.level_name

    # newbie
    u1.stub(:newbie?, true) do
      assert_equal "newbie", u1.level
      assert_equal "Newbi", u1.level_name
    end

    u1 = User.new(state: :admin)
    assert_equal "admin", u1.level
    assert_equal "Admin", u1.level_name

    u1 = User.new(state: :maintainer)
    assert_equal "maintainer", u1.level
    assert_equal "Maintainer", u1.level_name

    # vip
    u1 = User.new(state: :vip)
    assert_equal "vip", u1.level
    assert_equal "VIP", u1.level_name

    # blocked
    u1 = User.new(state: :blocked)
    assert_equal "blocked", u1.level
    assert_equal "Banned", u1.level_name

    # blocked
    u1 = User.new(state: :deleted)
    assert_equal "deleted", u1.level
    assert_equal "Deleted", u1.level_name
  end


  test "#find_for_database_authentication" do
    user = create(:user, login: "foo", email: "foobar@gmail.com")

    assert_equal user.id, User.find_for_database_authentication(login: "foo").id
    assert_equal user.id, User.find_for_database_authentication(login: "foobar@gmail.com").id
    assert_nil User.find_for_database_authentication(login: "not found")

    # deleted user
    user.update(state: -1)
    assert_nil User.find_for_database_authentication(login: "foo")
  end

  test ".email_locked?" do
    assert_equal true, User.new(email: "foobar@gmail.com").email_locked?
    assert_equal false, User.new(email: "foobar@example.com").email_locked?
  end

  test ".team_options" do
    user2 = create(:user)

    team_users = create_list(:team_user, 2, user: user)
    teams = team_users.collect(&:team).sort
    assert_equal teams.collect { |t| [t.name, t.id] }.sort, user.team_options.sort
  end

  test ".team_options should get all with admin" do
    user2 = create(:user)

    ids1 = create_list(:team_user, 2, user: user).collect(&:team_id)
    ids2 = create_list(:team_user, 2, user: user2).collect(&:team_id)
    user.stub(:admin?, true) do
      assert_includes_all user.team_options.collect { |_, id| id }, *(ids1 + ids2)
    end
  end

  test ".indexed_changed?" do
    u = create :user, bio: "111", tagline: "222"

    # login changed work
    u.reload
    assert_equal false, u.indexed_changed?
    u.login = u.login + "111"
    u.save
    assert_equal true, u.indexed_changed?

    # name changed work
    u.reload
    assert_equal false, u.indexed_changed?
    u.update(name: u.name + "111")
    assert_equal true, u.indexed_changed?

    # other changed work
    u.reload
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

  test "#search" do
    @rei = create(:user, login: "Rei", replies_count: 5)
    @rain = create(:user, login: "rain")
    @huacnlee = create(:user, login: "huacnlee")
    @hugo = create(:user, login: "Hugo", name: "Rugo", replies_count: 2)
    @hot = create(:user, login: "hot")

    # should work simple query
    res = User.search("r")
    assert_equal @rei.id, res[0].id
    assert_equal @hugo.id, res[1].id
    assert_equal @rain.id, res[2].id

    assert_equal 3, User.search("r").size
    assert_equal 1, User.search("re").size
    assert_equal 3, User.search("h").size
    assert_equal 2, User.search("hu").size

    # should work with :user option to include following users first" do
    @rei.follow_user(@hugo)
    res = User.search("r", user: @rei, limit: 2)
    assert_equal @hugo.id, res[0].id
    assert_equal @rei.id, res[1].id
    assert_equal 2, res.length
  end

  test "github_repos_path" do
    user = User.new(github: "huacnlee")
    assert_equal "/users/huacnlee/repos?type=owner&sort=pushed", user.github_repos_path

    user = User.new(github: "")
    assert_nil user.github_repos_path
    assert_nil User.fetch_github_repositories(user.id)
  end
end
