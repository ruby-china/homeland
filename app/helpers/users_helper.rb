# coding: utf-8  
require "digest/md5"
module UsersHelper
  def user_name_tag(user,options = {})
    location = options[:location] || false
    return "匿名" if user.blank?
    result = %(<a href="#{user_path(user.login)}">#{user.login}</a>)
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
    html = ""
    if link
      html = %(<a href="#{user_path(user.login)}" #{user_popover_info(user)} class="user_avatar">#{img}</a>)
    else
      html = img
    end
    raw html
  end
  
  def user_popover_info(user)
    return "" if user.blank?
    return "" if user.location.blank?
    title = user.location.blank? ? "#{user.login}" : "<i>#{user.location}</i> #{user.login}"
    tagline = user.tagline.blank? ? "这哥们儿没签名" : truncate(user.tagline, :length => 20)
    raw %(rel="popover" data-placement="below" title="#{h(title)}" data-content="#{h(tagline)}")
  end
end
