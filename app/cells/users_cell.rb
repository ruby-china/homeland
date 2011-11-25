# coding: utf-8
class UsersCell < BaseCell
  # 活跃会员
  cache :hot_users, :expires_in => 1.days
  def hot_users
    @hot_users = User.hot.limit(20)
    render 
  end
end