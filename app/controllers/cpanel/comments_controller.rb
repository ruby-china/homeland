class Cpanel::CommentsController < Cpanel::ApplicationController

  def index
    @comments = Comment.recent.paginate(:page => params[:page], :per_page => 20)
  end

  def edit
    @comment = Comment.find(params[:id])
  end
  

  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:comment])
      redirect_to cpanel_comments_path(@cpanel_comment), notice: 'Comment was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end
end
