# frozen_string_literal: true

module Admin
  class RepliesController < Admin::ApplicationController
    before_action :set_reply, only: %i[show edit update destroy revert]

    def index
      @replies = Reply.unscoped
      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        @replies = @replies.where("body LIKE ?", qstr)
      end
      if params[:login].present?
        u = User.find_by_login(params[:login])
        @replies = @replies.where("user_id = ?", u.try(:id))
      end
      @replies = @replies.order(id: :desc).includes(:topic, :user)
      @replies = @replies.page(params[:page])
    end

    def show
      redirect_to edit_admin_reply_path(@reply.id)
    end

    def destroy
      @reply.destroy
    end

    def revert
      @reply.update_attribute(:deleted_at, nil)
      redirect_to(admin_replies_path)
    end

    private

    def set_reply
      @reply = Reply.unscoped.find(params[:id])
    end
  end
end
