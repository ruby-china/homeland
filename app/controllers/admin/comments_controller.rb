module Admin
  class CommentsController < Admin::ApplicationController
    before_action :set_comment, only: [:show, :edit, :update, :destroy]
    respond_to :js, :html, only: [:destroy]

    def index
      @comments = Comment.recent.includes(:user).paginate(page: params[:page], per_page: 20)
    end

    def edit
    end

    def update
      if @comment.update_attributes(params[:comment].permit!)
        redirect_to admin_comments_path(@admin_comment), notice: 'Comment was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @comment.destroy
      respond_with do |format|
        format.html { redirect_to admin_comments_path }
        format.js { render layout: false }
      end
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
