require 'digest/md5'

module UsersHelper
  include LetterAvatar::AvatarHelper

  # 生成用户 login 的链接，user 参数可接受 user 对象或者 字符串的 login
  def user_name_tag(user, options = {})
    return '匿名'.freeze if user.blank?

    if user.is_a? String
      user_type = :user
      login = user
      name  = login
    else
      user_type = user.user_type
      login = user_type == :team ? user.name : user.login
      name  = user.name
    end

    name ||= login
    options[:class] ||= "#{user_type}-name"
    options['data-name'.freeze] = name

    link_to(login, main_app.user_path(user), options)
  end
  alias team_name_tag user_name_tag

  def user_avatar_width_for_size(size)
    case size
    when :xs then 16
    when :sm then 32
    when :md then 48
    when :lg then 96
    else size
    end
  end

  def user_avatar_tag(user, version = :md, opts = {})
    width = user_avatar_width_for_size(version)
    img_class = "media-object avatar-#{width}"

    return image_tag("avatar/#{version}.png", class: img_class) if user.nil?

    img =
      if user.avatar?
        image_url = user.avatar.url(version)
        image_url += "?t=#{user.updated_at.to_i}" if opts[:timestamp] && Setting.upload_provider == 'upyun'
        image_tag(image_url, class: img_class)
      else
        image_tag(user.letter_avatar_url(width * 2), class: img_class)
      end

    return raw(img) if opts[:link] == false

    link_to raw(img), user_path(user)
  end
  alias team_avatar_tag user_avatar_tag

  def render_user_level_tag(user)
    return '' unless user
    level_class = case user.level
                  when 'admin'   then 'label-danger'
                  when 'vip'     then 'label-success'
                  when 'hr'      then 'label-success'
                  when 'blocked' then 'label-warning'
                  when 'newbie'  then 'label-default'
                  else 'label-info'
                  end

    content_tag(:span, user.level_name, class: "label #{level_class} role")
  end

  def block_node_tag(node)
    return '' if current_user.blank? || node.nil?
    blocked = current_user.blocked_node_ids.include?(node.id)
    icon = '<i class="fa fa-eye-slash"></i>'
    class_names = 'btn btn-default btn-sm button-block-node'
    if blocked
      class_names = "#{class_names} active"
      block_tag_builder icon: icon, span: '取消屏蔽', title: '忽略后，社区首页列表将不会显示这里的内容。', data_id: node.id, class_names: class_names
    else
      block_tag_builder icon: icon, span: '忽略节点', data_id: node.id, class_names: class_names
    end
  end

  def block_user_tag(user)
    return '' unless can_block_user?(user)
    blocked = current_user.blocked_user_ids.include?(user.id)
    icon = '<i class="fa fa-eye-slash"></i>'
    class_names = 'button-block-user btn btn-default btn-block'
    login = user.login
    if blocked
      class_names = "#{class_names} active"
      block_tag_builder icon: icon, span: '取消屏蔽', data_id: login, class_names: class_names,
                        title: '忽略后，社区首页列表将不会显示此用户发布的内容。'
    else
      block_tag_builder icon: icon, span: '屏蔽', data_id: login, class_names: class_names
    end
  end

  def follow_user_tag(user, opts = {})
    return '' unless can_follow_user?(user)
    followed = current_user.followed?(user)

    opts[:class] ||= 'btn btn-primary btn-block'
    class_names = "button-follow-user #{opts[:class]}"
    icon = '<i class="fa fa-user"></i>'
    login = user.login

    if followed
      class_names = "#{class_names} active"
      follow_tag_builder icon: icon, span: '取消关注', data_id: login, class_names: class_names
    else
      follow_tag_builder icon: icon, span: '关注', data_id: login, class_names: class_names
    end
  end

  private

  def block_tag_builder(opts = {})
    link_to raw("#{opts[:icon]}<span>#{opts[:span]}</span>"),
            '#',
            title: opts[:title],
            'data-id': opts[:data_id],
            class: opts[:class_names]
  end
  alias follow_tag_builder block_tag_builder

  def can_follow_user?(user)
    user && current_user && user.id != current_user.id
  end
  alias can_block_user? can_follow_user?
end
