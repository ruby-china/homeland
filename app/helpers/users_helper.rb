require 'digest/md5'
module UsersHelper
  # 生成用户 login 的链接，user 参数可接受 user 对象或者 字符串的 login
  def user_name_tag(user, options = {})
    return '匿名'.freeze if user.blank?

    if user.is_a? String
      login = user
      name = login
    else
      login = user.login
      name = user.name
    end

    name ||= login
    options['data-name'.freeze] = name

    link_to(login, user_path(login), options)
  end

  def user_avatar_width_for_size(size)
    case size
    when :normal then 48
    when :small then 16
    when :large then 96
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
    img_class = "media-object avatar-#{width}"

    if user.blank?
      # hash = Digest::MD5.hexdigest("") => d41d8cd98f00b204e9800998ecf8427e
      return image_tag("avatar/#{size}.png", class: img_class)
    end

    if user[:avatar].blank?
      img_src = "#{Setting.gravatar_proxy}/avatar/#{user.email_md5}.png?s=#{width * 2}&d=404"
      img = image_tag(img_src, class: img_class)
    else
      img = image_tag(user.avatar.url(user_avatar_size_name_for_2x(size)), class: img_class)
    end

    if link
      link_to(raw(img), user_path(user))
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
    link_to(user.github_url, user.github_url, target: '_blank', rel: 'nofollow')
  end

  def render_user_personal_website(user)
    website = user.website[%r{^https?://}] ? user.website : 'http://' + user.website
    link_to(website, website, target: '_blank', class: 'url', rel: 'nofollow')
  end

  def render_user_level_tag(user)
    if admin?(user)
      content_tag(:span, t('common.admin_user'), class: 'label label-danger role')
    elsif wiki_editor?(user)
      content_tag(:span, t('common.vip_user'), class: 'label label-success role')
    elsif user.blocked?
      content_tag(:span, t('common.blocked_user'), class: 'label label-warning role')
    elsif user.newbie?
      content_tag(:span, t('common.newbie_user'), class: 'label label-default role')
    else
      content_tag(:span, t('common.normal_user'), class: 'label label-info role')
    end
  end

  def block_node_tag(node)
    return '' if current_user.blank?
    return '' if node.blank?
    blocked = current_user.blocked_node_ids.include?(node.id)
    class_names = 'btn btn-default btn-sm button-block-node'
    icon = '<i class="fa fa-eye-slash"></i>'
    if blocked
      link_to raw("#{icon} <span>取消屏蔽</span>"), '#', title: '忽略后，社区首页列表将不会显示这里的内容。', 'data-id' => node.id, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>忽略节点</span>"), '#', title: '', 'data-id' => node.id, class: class_names
    end
  end

  def block_user_tag(user)
    return '' if current_user.blank?
    return '' if user.blank?
    return '' if current_user.id == user.id
    blocked = current_user.blocked_user_ids.include?(user.id)
    class_names = 'button-block-user btn btn-default btn-block'
    icon = '<i class="fa fa-eye-slash"></i>'
    if blocked
      link_to raw("#{icon} <span>取消屏蔽</span>"), '#', title: '忽略后，社区首页列表将不会显示此用户发布的内容。', 'data-id' => user.login, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>屏蔽</span>"), '#', title: '', 'data-id' => user.login, class: class_names
    end
  end

  def follow_user_tag(user, opts = {})
    return '' if current_user.blank?
    return '' if user.blank?
    return '' if current_user.id == user.id
    followed = current_user.followed?(user)
    opts[:class] ||= 'btn btn-primary btn-block'
    class_names = "button-follow-user #{opts[:class]}"
    icon = '<i class="fa fa-user"></i>'
    login = user.login.downcase
    if followed
      link_to raw("#{icon} <span>取消关注</span>"), '#', 'data-id' => login, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>关注</span>"), '#', title: '', 'data-id' => login, class: class_names
    end
  end
end
