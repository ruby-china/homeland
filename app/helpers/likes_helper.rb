# coding: utf-8
module LikesHelper
  # 喜欢功能
  # 参数
  # likeable - Like 的对象
  # :cache - 当为 true 时将不会监测用户是否喜欢过，直接返回未喜欢过的状态，以用于 cache 的场景
  def likeable_tag(likeable, opts = {})
    return "" if likeable.blank?

    # 没登录，并且也没用用 cache 的时候，直接返回会跳转倒登录的
    if opts[:cache].blank? && current_user.blank?
      return link_to(raw("<i class=\"icon small_like\"></i> <span>喜欢</span>"), new_user_session_path, class: "likeable")
    end

    label = "#{likeable.likes_count} 人喜欢"
    label = "喜欢" if likeable.likes_count == 0

    if opts[:cache].blank? && likeable.liked_by_user?(current_user)
      title = "取消喜欢"
      state = "liked"
      icon = content_tag("i", "", class: "icon small_liked")
    else
      title = "喜欢"
      state = ""
      icon = content_tag("i", "", class: "icon small_like")
    end
    like_label = raw "#{icon} <span>#{label}</span>"

    link_to(like_label, "#", title: title, rel: "twipsy", 'data-count' => likeable.likes_count,
          'data-state' => state, 'data-type' => likeable.class,'data-id' => likeable.id,
          class: 'likeable', onclick: "return App.likeable(this);")
  end
end
