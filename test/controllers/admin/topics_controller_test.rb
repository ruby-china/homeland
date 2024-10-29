require "spec_helper"

describe Admin::TopicsController do
  before do
    sign_in create(:admin)
  end

  it "GET /admin/topics" do
    get admin_topics_path
    assert_equal 200, response.status
  end

  it "GET /admin/topics/:id/edit" do
    topic = create :topic
    get edit_admin_topic_path(topic.id)
    assert_equal 200, response.status
  end
end
