# frozen_string_literal: true

require "test_helper"

class UsersHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "user_avatar_width_for_size should calculate avatar width correctly" do
    assert_equal 16, user_avatar_width_for_size(:xs)
    assert_equal 32, user_avatar_width_for_size(:sm)
    assert_equal 48, user_avatar_width_for_size(:md)
    assert_equal 96, user_avatar_width_for_size(:lg)
    assert_equal 233, user_avatar_width_for_size(233)
  end

  test "user_name_tag should result right html in normal" do
    user = build(:user)
    assert_equal link_to(user.login, user_path(user.login), class: "user-name", "data-name" => user.name), user_name_tag(user)
  end

  test "user_name_tag should result right html with string param and downcase url" do
    login = "Monster"
    assert_equal link_to(login, user_path(login), class: "user-name", "data-name" => login), user_name_tag(login)
  end

  test "user_name_tag should out name with Team" do
    user = build(:team)
    assert_equal link_to(user.name, user_path(user.login), class: "team-name", "data-name" => user.name), user_name_tag(user)
  end

  test "user_name_tag should result empty with nil param" do
    assert_equal "Unknow user", user_name_tag(nil)
  end

  test "user_avatar_tag should work if user not exist" do
    assert_equal "", user_avatar_tag(nil)
  end

  test "user_avatar_tag should work if user exists" do
    user = create(:user)
    img = image_tag(user.letter_avatar_url(96), class: "media-object avatar-48")
    assert_equal link_to(raw(img), user_path(user), title: user.fullname), user_avatar_tag(user)
  end

  test "user_avatar_tag should work if avatar exist" do
    user = create(:avatar_user)
    image_url = user.avatar.url(:md)
    img = image_tag(image_url, class: "media-object avatar-48")
    assert_equal link_to(raw(img), user_path(user), title: user.fullname), user_avatar_tag(user)
  end

  test "user_avatar_tag should work with different size" do
    assert_equal "", user_avatar_tag(nil, :lg)
  end

  test "user_avatar_tag should work with timestamp param" do
    user = create(:avatar_user)
    image_url = user.avatar.url(:md) + "?t=#{user.updated_at.to_i}"
    img = image_tag(image_url, class: "media-object avatar-48")
    assert_equal link_to(raw(img), user_path(user), title: user.fullname), user_avatar_tag(user, :md, timestamp: true)
  end

  test "user_avatar_tag should work if link is false" do
    user = create(:avatar_user)
    image_url = user.avatar.url(:md) + "?t=#{user.updated_at.to_i}"
    img = image_tag(image_url, class: "media-object avatar-48")
    assert_equal img, user_avatar_tag(user, :md, timestamp: true, link: false)
  end

  test "user_level_tag admin should work" do
    user = User.new(created_at: 30.days.ago)

    %w[admin vip hr maintainer blocked deleted newbie member].each do |level|
      user.stub(:level, level) do
        assert_equal %(<span class="badge-role role-#{level}" style="background: #{user.level_color};">#{user.level_name}</span>), user_level_tag(user)
      end
    end
  end

  test "reward_user_tag" do
    user = create(:user)
    assert_equal "", reward_user_tag(user)
    assert_equal "", reward_user_tag(nil)

    user.update_reward_fields(alipay: "xxx")
    html = reward_user_tag(user)
    assert_equal %(<a class="btn btn-success" data-remote="true" href="/#{user.login}/reward"><i class='icon fa fa-qrcode'></i> <span>Reward</span></a>), html
    html = reward_user_tag(user, class: "btn btn-default")
    assert_equal %(<a class="btn btn-default" data-remote="true" href="/#{user.login}/reward"><i class='icon fa fa-qrcode'></i> <span>Reward</span></a>), html
  end
end
