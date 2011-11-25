module PostsHelper
  def post_title_tag(post, opts = {})
    return "" if post.blank?
    link_to(post.title, post_path(post), :title => post.title )
  end
  
  def post_tags_tag(post, opts = {})
    return "" if post.blank? or post.tags.blank?
    limit = 5
    tags = post.tags
    tags = tags[0..limit-1] if tags.count > limit
    raw tags.collect { |tag| link_to(tag,posts_path(:tag => tag)) }.join(", ")
  end
end
