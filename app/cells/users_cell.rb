# coding: utf-8
class UsersCell < BaseCell
  # 活跃会员
  cache :active_users, :expires_in => 1.days
  def active_users
    @active_users = User.hot.limit(20)
    render
  end

  cache :recent_join_users, :expires_in => 1.hour
  def recent_join_users
    @recent_join_users = User.recent.limit(20)
    render
  end
end
