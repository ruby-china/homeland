# frozen_string_literal: true

require "spec_helper"

describe Admin::CommentsController do
  before do
    sign_in create(:admin)
    @comment = create :comment, commentable: CommentablePage.create(name: "Fake Wiki", id: 1)
  end

  it "GET /admin/comments" do
    get admin_comments_path
    assert_equal 200, response.status
  end

  it "GET /admin/comments/:id/edit" do
    get edit_admin_comment_path(@comment)
    assert_equal 200, response.status
  end

  describe "PUT /admin/comments/:id" do
    it "updates the requested comment" do
      comment_param = {body: "123"}
      # expect_any_instance_of(Comment).to receive(:update).with("body" => '123')
      put admin_comment_path(@comment), params: {comment: comment_param}
      @comment.reload
      assert_equal "123", @comment.body
    end

    it "redirects to the comment" do
      put admin_comment_path(@comment), params: {comment: {"body" => "body"}}
      assert_redirected_to admin_comments_url
    end
  end

  it "DELETE /admin/comments/:id" do
    assert_changes -> { Comment.count }, -1 do
      delete admin_comment_path(@comment)
    end
    assert_redirected_to admin_comments_url
  end
end
