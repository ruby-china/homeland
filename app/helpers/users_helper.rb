# coding: utf-8  
require "digest/md5"
module UsersHelper
  def user_name_tag(user,options = {})
    location = options[:location] || false
    return "匿名" if user.blank?
    result = "<a href=\"#{user_path(user.login)}\" title=\"#{user.login}\">#{user.login}</a>"
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
      width = 64
    else
      width = size
    end
    
    hash = (user.blank? or user.email.blank?) ? Digest::MD5.hexdigest("") : Digest::MD5.hexdigest(user.email) 
    return "<img src=\"http://www.gravatar.com/avatar/#{hash}?s=#{width}&d=identicon\" />" if user.blank?
   
    img_src = "http://www.gravatar.com/avatar/#{hash}?s=#{width}&d=identicon"
    img = "<img src=\"#{img_src}\" />"
    if link
      popover_title = user.location.blank? ? "#{user.login}" : "#{user.login} <small>#{user.location}</small>"
      popover_content = truncate( user.tagline, :length => 20 )
      raw("<a href=\"#{user_path(user.login)}\" class=\"user_avatar\" title=\"#{user.login}\" rel=\"popover\" data-placement=\"right\" data-popover-title=\"#{popover_title}\" data-popover-content=\"#{popover_content}\">#{img}</a>")

    else
      raw img
    end
  end
end
