# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :authenticate_user!, only: %i[create destroy]
  before_action :set_likeable

  def index
    @users = @item.like_by_users.order("actions.id asc")
    render :index, layout: false
  end

  def create
    current_user.like(@item)
    render plain: @item.reload.likes_count
  end

  def destroy
    current_user.unlike(@item)
    render plain: @item.reload.likes_count
  end

  private

  def set_likeable
    @success = false
    @element_id = "likeable_#{params[:type]}_#{params[:id]}"

    defined_action = User.find_defined_action(:like, params[:type])

    if defined_action.blank?
      render plain: "-1"
      return false
    end

    @item = defined_action[:target_klass].find_by(id: params[:id])
    render plain: "-2" if @item.blank?
  end
end
