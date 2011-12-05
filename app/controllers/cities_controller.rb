# coding: utf-8
class CitiesController < ApplicationController
  
  def index
    @cities = User.cities
  end
  
  def show
    @city = params[:id]
    @users = User.where(:location => @city)
  end
  
end
