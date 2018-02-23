# frozen_string_literal: true

module Homeland
  class Pipeline
    class MentionFilter < HTML::Pipeline::Filter
      MENTION_REGEXP = /#{NormalizeMentionFilter::PREFIX_REGEXP}@(user[0-9]{1,6})/io
      MENTION_REGEXP_IN_CODE = /#{NormalizeMentionFilter::PREFIX_REGEXP}@\z/i

      def call
        users = result[:normalize_mentions]
        link_mention_user_in_text!(doc, users)
        link_mention_user_in_code!(doc, users)
        doc
      end

      def link_mention_user_in_text!(doc, users)
        doc.xpath(".//text()").each do |node|
          content = node.to_html
          next unless content.include?("@")
          in_code = has_ancestor?(node, %w[pre code])
          content.gsub!(MENTION_REGEXP) do
            prefix = Regexp.last_match(1)
            user_placeholder = Regexp.last_match(2)
            user_id = user_placeholder.sub(/^user/, "").to_i
            user = users[user_id - 1] || user_placeholder

            if in_code
              "#{prefix}@#{user}"
            else
              %(#{prefix}<a href="/#{user}" class="user-mention" title="@#{user}"><i>@</i>#{user}</a>)
            end
          end

          node.replace(content)
        end
      end

      def link_mention_user_in_code!(doc, users)
        doc.css("pre.highlight span").each do |node|
          next unless node.previous&.inner_html.to_s =~ MENTION_REGEXP_IN_CODE && node.inner_html =~ /\Auser(\d+)\z/
          user_id = Regexp.last_match(1)
          user = users[user_id.to_i - 1]
          node.inner_html = user if user
        end
      end
    end
  end
end
