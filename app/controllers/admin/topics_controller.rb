# frozen_string_literal: true

module Admin
  class TopicsController < Admin::ApplicationController
    before_action :set_topic, only: %i[show edit update destroy revert suggest unsuggest]

    def index
      @topics = Topic.unscoped
      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        @topics = @topics.where("title LIKE ?", qstr)
      end
      if params[:login].present?
        u = User.find_by_login(params[:login])
        @topics = @topics.where("user_id = ?", u.try(:id))
      end
      @topics = @topics.order(id: :desc)
      @topics = @topics.includes(:node, :user).page(params[:page])
    end

    def show
      redirect_to edit_admin_topic_path(@topic.id)
    end

    def new
      @topic = Topic.new
    end

    def edit
    end

    def create
      @topic = Topic.new(params[:topic].permit!)

      if @topic.save
        redirect_to(admin_topics_path, notice: "话题创建成功")
      else
        render action: "new"
      end
    end

    def update
      if @topic.update(params[:topic].permit!)
        redirect_to(admin_topics_path, notice: "话题更新成功")
      else
        render action: "edit"
      end
    end

    def destroy
      @topic.destroy_by(current_user)

      redirect_to(admin_topics_path)
    end

    def revert
      @topic.update_attribute(:deleted_at, nil)
      redirect_to(admin_topics_path)
    end

    def suggest
      @topic.update_attribute(:suggested_at, Time.now)
      redirect_to(@topic, notice: t("topics.topic_pin_successfully"))
    end

    def unsuggest
      @topic.update_attribute(:suggested_at, nil)
      redirect_to(@topic, notice: t("topics.topic_unpin_successfully"))
    end

    private

    def set_topic
      @topic = Topic.unscoped.find(params[:id])
    end
  end
end
