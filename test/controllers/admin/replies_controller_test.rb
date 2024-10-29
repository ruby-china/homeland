require "spec_helper"

describe Admin::RepliesController do
  before do
    sign_in create(:admin)
  end

  it "GET /admin/replies" do
    get admin_replies_path
    assert_equal 200, response.status
  end

  it "GET /admin/replies/:id/edit" do
    reply = create :reply
    get edit_admin_reply_path(reply.id)
    assert_equal 200, response.status
  end

  it "DELETE /admin/replies/:id" do
    reply = create :reply
    delete admin_reply_path(reply.id), params: { format: :js }
    assert_equal 200, response.status
    assert_nil Reply.find_by_id(reply.id)
  end
end
