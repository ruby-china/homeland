# frozen_string_literal: true

module Admin
  class UsersController < Admin::ApplicationController
    def index
      scope = User.all
      scope = scope.where(type: params[:type]) if params[:type].present?
      scope = scope.where(state: params[:state]) if params[:state].present?
      field = params[:field] || "login"

      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        scope = case field
        when "login"
          scope.where("lower(login) LIKE ?", qstr)
        when "email"
          scope.where("lower(email) LIKE ?", qstr)
        when "name"
          scope.where("lower(name) LIKE ?", qstr)
        when "tagline"
          scope.where("lower(tagline) LIKE ?", qstr)
        end

      end

      @users = scope.order(id: :desc).page(params[:page])
    end

    def show
      @user = User.find(params[:id])
    end

    def new
      @user = User.new
      @user._id = nil
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @user = User.new(params[:user].permit!)
      @user.email = params[:user][:email]
      @user.login = params[:user][:login]
      @user.state = params[:user][:state]

      if @user.save
        redirect_to(admin_users_path, notice: "User was successfully created.")
      else
        render action: "new"
      end
    end

    def update
      @user = User.find_by_login!(params[:id])
      type = @user.user_type # Can be :team or :user

      @user.email = params[type][:email]
      @user.login = params[type][:login]
      @user.state = params[type][:state] if params[type][:state] # Avoid `ActiveRecord::NotNullViolation` exception for Team entity.

      if @user.update(params[type].permit!)
        redirect_to(edit_admin_user_path(@user.id), notice: "User was successfully updated.")
      else
        render action: "edit"
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.user_type == :user
        @user.soft_delete
      else
        @user.destroy
      end

      respond_to do |format|
        format.js
        format.html { redirect_to(edit_admin_user_url(@user.id)) }
      end
    end

    def clean
      @user = User.find_by_login!(params[:id])
      case params[:type]
      when "replies"
        _clean_replies
      when "topics"
        _clean_topics
      when "photos"
        _clean_photos
      when "notes"
        _clean_notes
      end
    end

    def _clean_replies
      # For avoid mistakenly deelete a lot of record, we limit delete 10 items.
      ids = Reply.unscoped.where(user_id: @user.id).recent.limit(10).pluck(:id)
      replies = Reply.unscoped.where(id: ids)
      topics = Topic.where(id: replies.collect(&:topic_id))
      replies.delete_all
      topics.each(&:touch)

      count = Reply.unscoped.where(user_id: @user.id).count
      redirect_to edit_admin_user_path(@user.id), notice: "Recent 10 replies has been deleted successfully, now #{@user.login} still #{count} replies"
    end

    def _clean_topics
      Topic.unscoped.where(user_id: @user.id).recent.limit(10).delete_all
      count = Topic.unscoped.where(user_id: @user.id).count
      redirect_to edit_admin_user_path(@user.id), notice: "Recent 10 topics has been deleted successfully, now #{@user.login} still #{count} topics"
    end

    def _clean_photos
      Photo.unscoped.where(user_id: @user.id).recent.limit(10).destroy_all
      count = Photo.unscoped.where(user_id: @user.id).count
      redirect_to edit_admin_user_path(@user.id), notice: "Recent 10 photos has been deleted successfully, now #{@user.login} still #{count} photos"
    end

    def _clean_notes
      count = 0
      if defined? Note
        Note.unscoped.where(user_id: @user.id).recent.limit(10).destroy_all
        count = Note.unscoped.where(user_id: @user.id).count
      end
      redirect_to edit_admin_user_path(@user.id), notice: "Recent 10 notes has been deleted successfully, now #{@user.login} still #{count} notes"
    end
  end
end
