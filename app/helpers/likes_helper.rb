# frozen_string_literal: true

module LikesHelper
  # Likeable Helper
  #
  # 参数
  # - likeable - Like 的对象
  # - :cache - 当为 true 时将不会监测用户是否赞过，直接返回未赞过的状态，以用于 cache 的场景
  # - :class - 增加 a 标签的 css class, 例如 "btn btn-default"
  def likeable_tag(likeable, opts = {})
    return "" if likeable.blank?

    label = "#{likeable.likes_count} 个赞"
    label = "" if likeable.likes_count == 0

    liked = false

    if opts[:cache].blank? && current_user
      target_type = likeable.class.name
      defined_action = User.find_defined_action(:like, target_type)
      return "" unless defined_action

      liked = current_user.send("like_#{defined_action[:action_name]}_ids").include?(likeable.id)
    end

    title, state, icon_name =
      if opts[:cache].blank? && liked
        %w[取消赞 active heart]
      else
        %w[赞 deactive heart]
      end

    icon_label = icon_tag(icon_name, label: label)
    css_classes = ["likeable", state]
    css_classes << opts[:class] if opts[:class]

    data = {
      count: likeable.likes_count,
      state: state,
      type: likeable.class.name,
      id: likeable.id
    }

    link_to(icon_label, "#", title: title, data: data, class: css_classes.join(" "))
  end
end
