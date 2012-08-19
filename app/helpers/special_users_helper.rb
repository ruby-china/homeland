#coding:utf-8
#用于处理view中特殊用户名连接的帮助类
module SpecialUsersHelper
  #特殊用户名单,将有歧义的用户名列在此处
  SPECIAL_USER_NAMES ||= %w{topics wiki sites notes notifications nodes search api 404 422 500}

  #拦截user_path方法,有歧义的用户路径转换为/user/:id
  def user_path user
    user = user.name unless user.instance_of? String
    if SPECIAL_USER_NAMES.include? user
      "/u/#{user}"
    else
      "/#{user}"
    end
  end

  def topics_user_path user
    user_path(user) << "/topics"
  end

  def favorites_user_path user
    user_path(user) << "/favorites"
  end
end
