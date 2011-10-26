# coding: utf-8  
require "digest/md5"
module UsersHelper
  def user_name_tag(user,options = {})
    location = options[:location] || false
    return "匿名" if user.blank?
    result = "<a href=\"#{user_path(user.login)}\" title=\"#{user.name}\">#{user.name}</a>"
    if location
      if !user.location.blank?
        result += " <span class=\"location\" title=\"门牌号\">[#{user.location}]</span>"
      end
    end
    raw(result)
  end
  

  def user_avatar_tag(user,size = :normal, opts = {})
    link = opts[:link] || true
    width = 48
    case size
    when :normal
      width = 48
    when :small
      width = 16
    when :large
      width = 80
    else
      width = size
    end
    
    hash = (user.blank? or user.email.blank?) ? Digest::MD5.hexdigest("") : Digest::MD5.hexdigest(user.email) 
    return "<img src=\"http://www.gravatar.com/avatar/#{hash}?s=#{width}\" />" if user.blank?
   
    img_src = "http://www.gravatar.com/avatar/#{hash}?s=#{width}"
    img = "<img src=\"#{img_src}\" />"
    if link
      raw("<a href=\"#{user_path(user.login)}\" title=\"#{user.name}\">#{img}</a>")
    else
      raw img
    end
  end
end
