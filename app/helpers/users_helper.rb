# coding: utf-8  
require "digest/md5"
module UsersHelper
  def user_name_tag(user,options = {})
    location = options[:location] || false
    return "匿名" if user.blank?
    result = link_to(user.login, user_path(user.login))
    return result
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
    return image_tag("http://www.gravatar.com/avatar/#{hash}?s=#{width}&d=identicon")  if user.blank?
    
    img_src = "http://www.gravatar.com/avatar/#{hash}?s=#{width}&d=identicon"
    img = image_tag(img_src)
    html = ""
    if link
      html = %(<a href="#{user_path(user.login)}" #{user_popover_info(user)} class="user_avatar">#{img}</a>)
    else
      html = img
    end
    raw html
  end
  
  def render_user_location(user)
    return user.location
  end
  
  def render_user_join_time(user)
    I18n.l(user.created_at.to_date, :format => :long)
  end
  
  def render_user_tagline(user)
    return user.tagline
  end
  
  def render_user_github_url(user)
    link_to(user.github_url, user.github_url, :target => "_blank", :rel => "nofollow")
  end
  
  def render_user_personal_website(user)
    link_to(user.website, user.website, :target => "_blank", :rel => "nofollow")
  end
  
  def render_user_level_tag(user)
    if admin?(user)
      content_tag(:span, "管理员", :class => "label warning")
    elsif wiki_editor?(user)
      content_tag(:span, "Wiki 管理", :class => "label success")
    else
      content_tag(:span, "普通用户", :class => "label")
    end
  end
  
  private
  
  def user_popover_info(user)
    return "" if user.blank?
    return "" if user.location.blank?
    title = user.location.blank? ? "#{user.login}" : "<i>#{user.location}</i> #{user.login}"
    tagline = user.tagline.blank? ? "这哥们儿没签名" : truncate(user.tagline, :length => 20)
    raw %(rel="popover" data-placement="below" title="#{h(title)}" data-content="#{h(tagline)}")
  end
end
