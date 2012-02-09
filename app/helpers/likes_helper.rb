# coding: utf-8
module LikesHelper
  # 收藏功能
  def likeable_tag(likeable)
    if current_user && likeable.liked_by_user?(current_user)
      link_to("","#",:title => "取消喜欢", :rel => "twipsy",
              'data-state' => 'liked','data-type' => likeable.class,'data-id' => likeable.id,
              :class => "icon small_liked", :onclick => "return App.likeable(this);")
    else
      link_to("","#",:title => "喜欢(可用于收藏此贴)", :rel => "twipsy",
              'data-state' => '', 'data-type' => likeable.class, 'data-id' => likeable.id,
              :class => "icon small_like", :onclick => "return App.likeable(this);")
    end
  end
end