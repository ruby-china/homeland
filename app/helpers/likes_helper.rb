module LikesHelper
  # 赞功能
  # 参数
  # likeable - Like 的对象
  # :cache - 当为 true 时将不会监测用户是否赞过，直接返回未赞过的状态，以用于 cache 的场景
  def likeable_tag(likeable, opts = {})
    return '' if likeable.blank?

    label = "#{likeable.likes_count} 个赞"
    label = '' if likeable.likes_count == 0

    liked = false

    if opts[:cache].blank? && current_user
      if likeable.is_a?(Topic)
        liked = current_user.like_topic_ids.include?(likeable.id)
      elsif likeable.is_a?(Reply)
        liked = current_user.like_reply_ids.include?(likeable.id)
      end
    end

    title, state, icon_name =
      if opts[:cache].blank? && liked
        ['取消赞', 'active', 'heart']
      else
        ['赞', '', 'heart']
      end
    icon = content_tag('i', '', class: "fa fa-#{icon_name}")
    like_label = raw "#{icon} <span>#{label}</span>"

    link_to(like_label, '#', title: title, 'data-count' => likeable.likes_count,
                             'data-state' => state, 'data-type' => likeable.class, 'data-id' => likeable.id,
                             class: "likeable #{state}")
  end
end
