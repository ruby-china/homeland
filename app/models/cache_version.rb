# frozen_string_literal: true
# Save speical cache version
# For example:
#    Record last update, pin topic time for update cache_key to expire cache that used this key.
#
# Usage:
#   Topic after_suggest ->
#   CacheVersion.topic_last_suggested_at = Time.now
#  In View <% cache("topic/index/sidebar_suggest:#{CacheVersion.topic_last_suggested_at}") do %><% end %>
class CacheVersion
  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)
  rescue NoMethodError
    if method_name.match?(/=$/)
      var_name = method_name.sub("=", "")
      key      = CacheVersion.mk_key(var_name)
      value    = args.first.to_s
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
