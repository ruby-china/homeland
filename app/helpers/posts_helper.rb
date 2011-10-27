module PostsHelper
  def post_title_tag(post, opts = {})
    return "" if post.blank?
    raw "<a href='#{post_path(post.id)}' title='#{post.title}'>#{post.title}</a>"
  end
  
  def post_tags_tag(post, opts = {})
    return "" if post.blank? or post.tags.blank?
    limit = 5
    tags = post.tags
    tags = tags[0..limit-1] if tags.count > limit
    raw tags.collect { |tag| "<a href='#{tag_posts_path(tag)}' class='tag'>#{tag}</a>" }.join(", ")
  end
end
