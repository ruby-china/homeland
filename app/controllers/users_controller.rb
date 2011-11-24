# coding: utf-8  
class UsersController < ApplicationController
  
  def index
  end
  
  def show
    @user = User.where(:login => params[:id]).first
    @last_topics = @user.topics.recent.limit(20)          
    @last_replies = @user.replies.only(:topic_id, :body, :created_at).recent.includes(:topic).limit(10)
    set_seo_meta("#{@user.login}")
  end
  
end
