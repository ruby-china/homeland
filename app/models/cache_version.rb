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
  class << self
    def method_missing(method, *args)
      method_name = method.to_s
      super(method, *args)
    rescue NoMethodError
      if method_name.match?(/=$/)
        var_name = method_name.sub("=", "")
        key = cache_key(var_name)
        value = args.first.to_s
        # save
        Rails.cache.write(key, value)
      else
        key = cache_key(method)
        Rails.cache.read(key)
      end
    end

    def respond_to_missing?
      true
    end

    def cache_key(key)
      "cache_version:#{key}"
    end
  end
end
