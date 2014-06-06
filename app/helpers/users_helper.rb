# coding: utf-8
require "digest/md5"
module UsersHelper
  # 生成用户 login 的链接，user 参数可接受 user 对象或者 字符串的 login
  def user_name_tag(user,options = {})
    return "匿名" if user.blank?

    if (user.class == "".class)
      login = user
      name = login
    else
      login = user.login
      name = user.name
    end

    name ||= login
    options['data-name'] = name

    link_to(login, user_path(login.downcase), options)
  end

  def user_avatar_width_for_size(size)
    case size
      when :normal then 48
      when :small then 16
      when :large then 64
      when :big then 120
      else size
    end
  end

  def user_avatar_size_name_for_2x(size)
    case size
    when :normal then :large
    when :small then :normal
    when :large then :big
    when :big then :big
    else size
    end
  end

  def user_avatar_tag(user, size = :normal, opts = {})
    link = opts[:link] || true

    width = user_avatar_width_for_size(size)

    if user.blank?
      # hash = Digest::MD5.hexdigest("") => d41d8cd98f00b204e9800998ecf8427e
      return image_tag("avatar/#{size}.png", class: "uface")
    end

    if user[:avatar].blank?
      default_url = asset_path("avatar/#{size}.png")
      img_src = "#{Setting.gravatar_proxy}/avatar/#{user.email_md5}.png?s=#{width * 2}&d=404"
      img = image_tag(img_src, class: "uface", style: "width:#{width}px;height:#{width}px;")
    else
      img = image_tag(user.avatar.url(user_avatar_size_name_for_2x(size)), class: "uface", style: "width:#{width}px;height:#{width}px;")
    end

    if link
      link_to(raw(img), user_path(user.login))
    else
      raw img
    end
  end

  def render_user_join_time(user)
    I18n.l(user.created_at.to_date, format: :long)
  end

  def render_user_tagline(user)
    user.tagline
  end

  def render_user_github_url(user)
    link_to(user.github_url, user.github_url, target: "_blank", rel: "nofollow")
  end

  def render_user_personal_website(user)
    website = user.website[/^https?:\/\//] ? user.website : "http://" + user.website
    link_to(website, website, target: "_blank", class: "url", rel: "nofollow")
  end

  def render_user_level_tag(user)
    if admin?(user)
      content_tag(:span, t("common.admin_user"), class: "label warning role")
    elsif wiki_editor?(user)
      content_tag(:span, t("common.vip_user"), class: "label success role")
    elsif user.newbie?
      content_tag(:span, t("common.newbie_user"), class: "label role")
    else
      content_tag(:span, t("common.normal_user"), class: "label role")
    end
  end

end
