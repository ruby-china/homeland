# coding: utf-8  
module UsersHelper
  def user_name_tag(user,options = {})
    location = options[:location] || false
    result = "<a href=\"#{user_path(user.id)}\" title=\"#{user.name}\">#{user.name}</a>"
    if location
      if !user.location.blank?
        result += " <span class=\"location\" title=\"门牌号\">[#{user.location}]</span>"
      end
    end
    raw(result)
  end
  

  def user_avatar_tag(user,size = :normal)
    url = eval("user.avatar.#{size.to_s}.url")
    raw("<a href=\"#{user_path(user.id)}\" title=\"#{user.name}\">#{image_tag(url)}</a>")
  end
end
