# frozen_string_literal: true

module Homeland
  class Pipeline
    class AutoCorrectFilter < HTML::Pipeline::Filter
      def call
        doc.xpath(".//text()").each do |node|
          content = node.to_html
          next if has_ancestor?(node, %w[pre code])

          html = AutoCorrect.format(content)

          next if html == content
          node.replace(html)
        end
        doc
      end
    end
  end
end
