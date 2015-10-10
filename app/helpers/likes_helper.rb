module LikesHelper
  # 赞功能
  # 参数
  # likeable - Like 的对象
  # :cache - 当为 true 时将不会监测用户是否赞过，直接返回未赞过的状态，以用于 cache 的场景
  def likeable_tag(likeable, opts = {})
    return '' if likeable.blank?

    # 没登录，并且也没用用 cache 的时候，直接返回会跳转倒登录的
    return unlogin_likeable_tag if opts[:cache].blank? && current_user.blank?

    label = "#{likeable.likes_count} 个赞"
    label = '' if likeable.likes_count == 0

    if opts[:cache].blank? && likeable.liked_by_user?(current_user)
      title = '取消赞'
      state = 'followed'
      icon = content_tag('i', '', class: 'fa fa-thumbs-up')
    else
      title = '赞'
      state = ''
      icon = content_tag('i', '', class: 'fa fa-thumbs-up')
    end
    like_label = raw "#{icon} <span>#{label}</span>"

    link_to(like_label, '#', title: title, 'data-count' => likeable.likes_count,
                             'data-state' => state, 'data-type' => likeable.class, 'data-id' => likeable.id,
                             class: "likeable #{state}")
  end

  private

  def unlogin_likeable_tag
    link_to(raw("<i class=\"fa fa-thumbs-up\"></i> <span></span>"), new_user_session_path, class: '')
  end
end
