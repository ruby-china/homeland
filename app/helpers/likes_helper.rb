# coding: utf-8
module LikesHelper
  # 收藏功能
  def likeable_tag(likeable)
    liked = false
    if current_user
      if Like.where(:likeable_type => likeable.class, :likeable_id => likeable.id, :user_id => current_user.id).count > 0
        liked = true
      end
    end
    
    if liked
      link_to("","#",:title => "取消喜欢",
              'data-state' => 'liked','data-type' => likeable.class,'data-id' => likeable.id,
              :class => "icon small_liked", :onclick => "return App.likeable(this);")
    else
      link_to("","#",:title => "喜欢",
              'data-state' => '', 'data-type' => likeable.class, 'data-id' => likeable.id,
              :class => "icon small_like", :onclick => "return App.likeable(this);")
    end
  end
end