# frozen_string_literal: true

require "test_helper"

class LikesHelperTest < ActionView::TestCase
  include ApplicationHelper

  attr_accessor :user, :topic, :reply

  setup do
    @user = create :user
    @topic = create :topic
    @reply = create :reply
  end

  test "should run with nil param" do
    assert_equal "", likeable_tag(nil)
  end

  test "should result when logined user liked" do
    sign_in user
    user.like_topic_ids = [topic.id]
    assert_equal %(<a title="Unlike" data-count="0" data-state="active" data-type="Topic" data-id="#{topic.id}" class="likeable active" href="#"><i class='icon fa fa-heart'></i> <span></span></a>), likeable_tag(topic)

    topic.likes_count = 3
    assert_equal %(<a title="Unlike" data-count="3" data-state="active" data-type="Topic" data-id="#{topic.id}" class="likeable active" href="#"><i class='icon fa fa-heart'></i> <span>3 likes</span></a>), likeable_tag(topic)
  end

  test "should result when unlogin user" do
    assert_equal %(<a title="Unlike" data-count="0" data-state="deactive" data-type="Topic" data-id="#{topic.id}" class="likeable deactive" href="#"><i class='icon fa fa-heart'></i> <span></span></a>), likeable_tag(topic)
  end

  test "should result with no_cache params" do
    str = %(<a title="Unlike" data-count="0" data-state="deactive" data-type="Topic" data-id="#{topic.id}" class="likeable deactive" href="#"><i class='icon fa fa-heart'></i> <span></span></a>)
    sign_in user
    assert_equal str, likeable_tag(topic, cache: true)
  end

  test "should allow addition class" do
    sign_in user
    assert_equal %(<a title="Unlike" data-count="0" data-state="deactive" data-type="Reply" data-id="#{reply.id}" class="likeable deactive btn btn-default" href="#"><i class='icon fa fa-heart'></i> <span></span></a>), likeable_tag(reply, class: "btn btn-default")
  end
end
