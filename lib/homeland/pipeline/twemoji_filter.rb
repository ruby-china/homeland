module Homeland
  class Pipeline
    class TwemojiFilter < HTML::Pipeline::Filter
      def call
        doc.xpath(".//text()").each do |node|
          content = node.to_html
          next unless content.include?(":")
          next if has_ancestor?(node, %w[pre code])

          html = Twemoji.parse(content)

          next if html == content
          node.replace(html)
        end
        doc
      end
    end
  end
end
