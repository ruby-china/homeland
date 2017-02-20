# 用于记录特定的 cache version
# 比如:
#    记录最后更新 置顶话题的时间,以用于作为自动变换置顶那个 cache 的 key，以达到自动过期的目的
# 用法例子:
#   以上面个场景为例
#   Topic after_suggest ->
#   CacheVersion.topic_last_suggested_at = Time.now
#  View 里面 <% cache("topic/index/sidebar_suggest:#{CacheVersion.topic_last_suggested_at}") do %><% end %>
class CacheVersion
  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)
  rescue NoMethodError
    if method_name.match?(/=$/)
      var_name = method_name.sub('='.freeze, ''.freeze)
      key = CacheVersion.mk_key(var_name)
      value = args.first.to_s
      # save
      Rails.cache.write(key, value)
    else
      key = CacheVersion.mk_key(method)
      Rails.cache.read(key)
    end
  end

  def self.mk_key(key)
    "cache_version:#{key}"
  end
end
