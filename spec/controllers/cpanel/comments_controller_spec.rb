require 'rails_helper'

describe Cpanel::CommentsController, type: :controller do
  let(:user) {create :user}
  let(:comment) { create :comment, user: user }

  before do
    sign_in create(:admin)
  end

  describe 'GET index' do
    it 'assigns all cpanel_comments as @comments' do
      comment
      get :index
      expect(assigns(:comments)).to include(comment)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested comment as @comment' do
      get :edit, params: { id: comment.id }
      expect(assigns(:comment)).to eq(comment)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested comment' do
        comment_param = { body: '123' }
        # expect_any_instance_of(Comment).to receive(:update_attributes).with("body" => '123')
        put :update, params: { id: comment.id, comment: comment_param }
        comment.reload
        expect(comment.body).to eq '123'
      end

      it 'assigns the requested comment as @comment' do
        put :update, params: { id: comment.id, comment: { 'body' => 'body' } }
        expect(assigns(:comment)).to eq(comment)
      end

      it 'redirects to the comment' do
        put :update, params: { id: comment.id, comment: { 'body' => 'body' } }
        expect(response).to redirect_to(cpanel_comments_url)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested comment' do
      comment
      expect do
        delete :destroy, params: { id: comment.id }
      end.to change(Comment, :count).by(-1)
    end

    it 'redirects to the comments list' do
      comment
      delete :destroy, params: { id: comment.id }
      expect(response).to redirect_to(cpanel_comments_url)
    end
  end
end
