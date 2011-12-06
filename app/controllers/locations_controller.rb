# coding: utf-8
class LocationsController < ApplicationController
  
  def index
    @locations = User.locations
  end
  
  def show
    @location = params[:id]
    @users = User.where(:location => @location)
  end
  
end
