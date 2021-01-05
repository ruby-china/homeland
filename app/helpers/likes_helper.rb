# frozen_string_literal: true

module LikesHelper
  # Likeable Helper
  #
  # params
  # - likeable - Like target
  # - :cache - when true, will not check current user is liked, directly return no like status for cache.
  # - :class - Add class for link, for example: "btn btn-default"
  def likeable_tag(likeable, opts = {})
    return "" if likeable.blank?

    label = "#{likeable.likes_count} #{t("common.likes")}"
    label = "" if likeable.likes_count == 0

    liked = false

    if opts[:cache].blank? && current_user
      target_type = likeable.class.name
      defined_action = User.find_defined_action(:like, target_type)
      return "" unless defined_action

      liked = current_user.send("like_#{defined_action[:action_name]}_ids").include?(likeable.id)
    end

    if opts[:cache].blank? && liked
      title = t("common.unlike")
      state = "active"
    else
      title = t("common.unlike")
      state = "deactive"
    end

    icon_label = icon_tag("heart", label: label)
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
