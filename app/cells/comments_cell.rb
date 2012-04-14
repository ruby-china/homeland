# -*- encoding : utf-8 -*-
class CommentsCell < BaseCell
  def index(opts)
    @title = opts[:title] || "评论"
    @commentable = opts[:commentable]
    @current_user = opts[:current_user]
    @comments = Comment.where(:commentable_type => @commentable.class.name,
                              :commentable_id => @commentable.id).includes(:user)
    @comment = Comment.new(:commentable_type => @commentable.class.name,
                           :commentable_id => @commentable.id)

    render
  end
end
