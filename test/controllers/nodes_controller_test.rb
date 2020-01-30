# frozen_string_literal: true

require "spec_helper"

describe NodesController do
  let(:node) { create(:node) }
  let(:user) { create(:user) }

  it "GET /nodes" do
    get nodes_path
    assert_equal 200, response.status
  end

  it "POST /nodes/id/block" do
    sign_in user
    post block_node_path(node)
    assert_equal 200, response.status
  end

  it "POST /nodes/id/unblock" do
    sign_in user
    post unblock_node_path(node)
    assert_equal 200, response.status
  end
end
