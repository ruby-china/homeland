module Homeland
  class Pipeline
    class FloorFilter < HTML::Pipeline::Filter
      FLOOR_REGEXP = /#(\d+)([楼樓Ff])/

      def call
        doc.search(".//text()").each do |node|
          content = node.to_html
          next unless content.include?("#")
          next if has_ancestor?(node, %w(pre code))

          content.gsub!(FLOOR_REGEXP) do
            %(<a href="#reply#{Regexp.last_match(1)}" class="at_floor" data-floor="#{Regexp.last_match(1)}">##{Regexp.last_match(1)}#{Regexp.last_match(2)}</a>)
          end

          node.replace(content)
        end
        doc
      end
    end
  end
end
