module Admin
  class CommentsController < ApplicationController
    respond_to :js, :html, only: [:destroy]

    def index
      @comments = Comment.recent.includes(:user).paginate(page: params[:page], per_page: 20)
    end

    def edit
      @comment = Comment.find(params[:id])
    end

    def update
      @comment = Comment.find(params[:id])

      if @comment.update_attributes(params[:comment].permit!)
        redirect_to admin_comments_path(@admin_comment), notice: 'Comment was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @comment = Comment.find(params[:id])
      @comment.destroy
      respond_with do |format|
        format.html { redirect_to admin_comments_path }
        format.js { render layout: false }
      end
    end
  end
end
