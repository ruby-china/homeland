# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!, only: [:users]

  def index
    params[:q] ||= ""
    @klass = (params[:type] || "topic").classify.constantize

    limit = 20
    offset = ((params[:page] || 1).to_i - 1) * limit

    search_params = {
      limit: limit,
      offset: offset,
      attributesToHighlight: "*",
    }

    @result = @klass.__meilisearch_index.search(params[:q], search_params)
  end

  def users
    @result = User.search(params[:q], user: current_user, limit: params[:limit] || 10)
    render json: @result.collect { |u| { login: u.login, name: u.name, avatar_url: u.large_avatar_url } }
  end
end
