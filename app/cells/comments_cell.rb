# coding: utf-8
class CommentsCell < BaseCell
  def index(opts)
    @commentable = opts[:commentable]
    @current_user = opts[:current_user]
    @comments = Comment.where(commentable_type: @commentable.class.name,
                              commentable_id: @commentable.id).includes(:user)
    @comment = Comment.new(commentable_type: @commentable.class.name,
                           commentable_id: @commentable.id)

    render
  end
end
