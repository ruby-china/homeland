class ApplicationsController < ApplicationController
  before_action :require_user
  
  def index
    
  end
  
  def new
    @application = Doorkeeper::Application.new
  end
  
  def create
  end
end