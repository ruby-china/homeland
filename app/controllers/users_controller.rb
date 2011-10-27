# coding: utf-8  
class UsersController < ApplicationController
  def show
    @user = User.where(:login => params[:id]).first
    @last_topics = @user.topics.recent.limit(20)          
    @last_replies = @user.replies.only(:topic_id).recent.limit(50).group
    set_seo_meta("#{@user.name}")
  end
  
end
