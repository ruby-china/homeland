# frozen_string_literal: true

require "test_helper"

class NotifyTopicNodeChangedJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  attr_accessor :topic, :user

  setup do
    @topic = create(:topic)
    @user = create(:user)
  end

  test ".perform" do
    topic = create(:topic, user: user)
    new_node = create(:node)
    admin = create(:admin)

    NotifyTopicNodeChangedJob.perform_now(topic.id, node_id: new_node.id)
    last_notification = user.notifications.unread.where(notify_type: "node_changed").first
    assert_equal "Topic", last_notification.target_type
    assert_equal topic.id, last_notification.target_id
    assert_equal "Node", last_notification.second_target_type
    assert_equal new_node.id, last_notification.second_target_id

    # on save callback, with admin_editing no node_id changed
    Current.stubs(:user).returns(admin)
    assert_no_performed_jobs(only: NotifyTopicNodeChangedJob) do
      topic.save
    end

    # on save callback, with admin_editing and node_id_changed
    Current.stubs(:user).returns(admin)
    topic.node_id = new_node.id
    assert_performed_jobs(1, only: NotifyTopicNodeChangedJob) do
      topic.save
    end

    # on save callback, without admin_editing
    Current.stubs(:user).returns(user)
    topic.node_id = new_node.id
    assert_no_performed_jobs(only: NotifyTopicNodeChangedJob) do
      topic.save
    end
  end
end
