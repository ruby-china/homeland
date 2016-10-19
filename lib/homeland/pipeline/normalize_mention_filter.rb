module Homeland
  class Pipeline
    class NormalizeMentionFilter < HTML::Pipeline::TextFilter
      NORMALIZE_USER_REGEXP = /(^|[^a-zA-Z0-9\-_!#\/\$%&*@＠])@([a-zA-Z0-9\-_]{1,20})/io

      def call
        users = []
        # Makesure clone a new value, not change original value
        text = @text.clone
        text.gsub!(NORMALIZE_USER_REGEXP) do
          prefix = Regexp.last_match(1)
          user = Regexp.last_match(2)
          users.push(user)
          "#{prefix}@user#{users.size}"
        end
        result[:normalize_mentions] = users
        text
      end
    end
  end
end
