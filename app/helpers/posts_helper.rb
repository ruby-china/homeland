# coding: utf-8
module PostsHelper
  def post_title_tag(post, opts = {})
    return "" if post.blank?
    link_to(post.title, post_path(post), :title => post.title)
  end

  def post_tags_tag(post, opts = {})
    return "" if post.blank? or post.tags.blank?
    limit = 5
    tags = post.tags
    tags = tags[0..limit-1] if tags.count > limit
    raw tags.collect { |tag| link_to(tag,posts_path(:tag => tag)) }.join(", ")
  end

  def render_post_state_s(post)
    case post.state
    when 0 then content_tag(:span, "草稿", :class => "label important")
    else
      content_tag(:span, "已审核", :class => "label success")
    end
  end
end

