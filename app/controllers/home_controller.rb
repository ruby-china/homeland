# coding: utf-8  
class HomeController < ApplicationController
  before_filter :require_no_user, :only => [:login, :login_create]
  before_filter :require_user, :only => [:logout,:auth_unbind]
  skip_before_filter :verify_authenticity_token, :only => [:auth_callback]

  def index
  
    unless current_user.blank?
      redirect_to topics_path 
      return
    end
  end
  
end
