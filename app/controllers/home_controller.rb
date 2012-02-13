# coding: utf-8
class HomeController < ApplicationController

  def index
    redirect_to topics_path unless current_user.blank?
  end
end
