# coding: utf-8  
module UsersHelper
  def user_name_tag(user)
    raw("<a href=\"#{user_path(user.id)}\" title=\"#{user.name}\">#{user.name}</a>")
  end

  def user_avatar_tag(user,size = :normal)
    raw("<a href=\"#{user_path(user.id)}\" title=\"#{user.name}\">#{image_tag(user.avatar(size))}</a>")
  end
end
