# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!, only: [:users]

  def index
    params[:q] ||= ""

    if params[:q].size > 64
      redirect_to root_path
    end

    @search = Homeland::Search.new(params[:q])

    @result = @search.query_results.includes(:searchable).page(params[:page])
  end

  def users
    @result = User.search(params[:q], user: current_user, limit: params[:limit] || 10)
    render json: @result.collect { |u| {login: u.login, name: u.name, avatar_url: u.large_avatar_url} }
  end
end
