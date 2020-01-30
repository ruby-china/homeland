# frozen_string_literal: true

require "rails_helper"

describe Admin::CommentsController, type: :controller do
  let(:user) { create :user }
  let(:comment) { create :comment, user: user, commentable: CommentablePage.create(name: "Fake Wiki", id: 1) }

  before do
    sign_in create(:admin)
  end

  describe "GET index" do
    it "should work" do
      comment
      get :index
      assert_equal 200, response.status
    end
  end

  describe "GET edit" do
    it "assigns the requested comment as @comment" do
      get :edit, params: { id: comment.id }
      assert_equal 200, response.status
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested comment" do
        comment_param = { body: "123" }
        # expect_any_instance_of(Comment).to receive(:update).with("body" => '123')
        put :update, params: { id: comment.id, comment: comment_param }
        comment.reload
        assert_equal "123", comment.body
      end

      it "redirects to the comment" do
        put :update, params: { id: comment.id, comment: { "body" => "body" } }
        assert_redirected_to admin_comments_url
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested comment" do
      comment
      expect do
        delete :destroy, params: { id: comment.id }
      end.to change(Comment, :count).by(-1)
    end

    it "redirects to the comments list" do
      comment
      delete :destroy, params: { id: comment.id }
      assert_redirected_to admin_comments_url
    end
  end
end
