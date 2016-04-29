require 'digest/md5'
module UsersHelper
  include LetterAvatar::AvatarHelper

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

    link_to(login, main_app.user_path(login), options)
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
    link = opts[:link].nil? ? true : opts[:link]

    width = user_avatar_width_for_size(size)
    img_class = "media-object avatar-#{width}"

    if user.blank?
      # hash = Digest::MD5.hexdigest("") => d41d8cd98f00b204e9800998ecf8427e
      return image_tag("avatar/#{size}.png", class: img_class)
    end

    img =
      if user.avatar?
        image_tag(user.avatar.url(user_avatar_size_name_for_2x(size)), class: img_class)
      else
        image_tag(user.letter_avatar_url(width * 2), class: img_class)
      end

    if link
      link_to(raw(img), user_path(user))
    else
      raw img
    end
  end

  def render_user_level_tag(user)
    return '' if user.blank?
    level_class = case user.level
                  when 'admin' then 'label-danger'
                  when 'vip' then 'label-success'
                  when 'hr' then 'label-success'
                  when 'blocked' then 'label-warning'
                  when 'newbie' then 'label-default'
                  else 'label-info'
                  end

    content_tag(:span, user.level_name, class: "label #{level_class} role")
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
