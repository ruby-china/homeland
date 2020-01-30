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
    assert_equal "匿名", user_name_tag(nil)
  end

  test "user_avatar_tag should work if user not exist" do
    assert_equal image_tag("avatar/md.png", class: "media-object avatar-48"), user_avatar_tag(nil)
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
    assert_equal image_tag("avatar/lg.png", class: "media-object avatar-96"), user_avatar_tag(nil, :lg)
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

  test "render_user_level_tag admin should work" do
    user = create(:user)

    # admin
    user.stub(:admin?, true) do
      assert_equal '<span class="badge badge-danger role">管理员</span>', render_user_level_tag(user)
    end

    # vip
    user.stub(:verified?, true) do
      assert_equal '<span class="badge badge-success role">高级会员</span>', render_user_level_tag(user)
    end

    # blocked
    user.stub(:blocked?, true) do
      assert_equal '<span class="badge badge-warning role">禁言用户</span>', render_user_level_tag(user)
    end

    # newbie
    user.stub(:newbie?, true) do
      assert_equal '<span class="badge badge-light role">新手</span>', render_user_level_tag(user)
    end

    # normal
    assert_equal '<span class="badge badge-info role">会员</span>', render_user_level_tag(user)
  end

  test "reward_user_tag" do
    user = create(:user)
    assert_equal "", reward_user_tag(user)
    assert_equal "", reward_user_tag(nil)

    user.update_reward_fields(alipay: "xxx")
    html = reward_user_tag(user)
    assert_equal %(<a class="btn btn-success" data-remote="true" href="/#{user.login}/reward"><i class='fa fa-qrcode'></i> <span>打赏支持</span></a>), html
    html = reward_user_tag(user, class: "btn btn-default")
    assert_equal %(<a class="btn btn-default" data-remote="true" href="/#{user.login}/reward"><i class='fa fa-qrcode'></i> <span>打赏支持</span></a>), html
  end
end
