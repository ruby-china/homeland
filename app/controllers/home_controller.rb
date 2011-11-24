# coding: utf-8  
class HomeController < ApplicationController

  def index
    unless current_user.blank?
      redirect_to topics_path 
      drop_breadcrumb("Hello")
      return
    end
  end

end
