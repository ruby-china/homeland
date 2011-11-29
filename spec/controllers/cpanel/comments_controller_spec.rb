require 'spec_helper'

describe Cpanel::CommentsController do
  let(:comment) { Factory :comment }

  before do
    sign_in Factory(:admin)
  end

  describe "GET index" do
    it "assigns all cpanel_comments as @comments" do
      comment
      get :index
      assigns(:comments).should include(comment)
    end
  end

  describe "GET edit" do
    it "assigns the requested comment as @comment" do
      get :edit, :id => comment.id
      assigns(:comment).should eq(comment)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested comment" do
        Comment.any_instance.should_receive(:update_attributes).with({'body' => 'params'})
        put :update, :id => comment.id, :comment => {'body' => 'params'}
      end

      it "assigns the requested comment as @comment" do
        put :update, :id => comment.id, :comment => {'body' => 'body'}
        assigns(:comment).should eq(comment)
      end

      it "redirects to the comment" do
        put :update, :id => comment.id, :comment => {'body' => 'body'}
        response.should redirect_to(cpanel_comments_url)
      end
    end

    describe "with invalid params" do
      it "assigns the comment as @comment" do
        Comment.any_instance.stub(:save).and_return(false)
        put :update, :id => comment.id, :comment => {}
        assigns(:comment).should eq(comment)
      end

      it "re-renders the 'edit' template" do
        Comment.any_instance.stub(:save).and_return(false)
        put :update, :id => comment.id, :comment => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested comment" do
      comment
      expect {
        delete :destroy, :id => comment.id
      }.to change(Comment, :count).by(-1)
    end

    it "redirects to the comments list" do
      comment
      delete :destroy, :id => comment.id
      response.should redirect_to(cpanel_comments_url)
    end
  end

end
