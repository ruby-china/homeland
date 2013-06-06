# coding: utf-8
class CommentsController < ApplicationController
  before_filter :require_user

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @success = @comment.save
  end
  
  def comment_params
    params.require(:comment).permit(:commentable_type, :commentable_id, :body)
  end
end
