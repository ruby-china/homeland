# frozen_string_literal: true

module Homeland
  class Html
    def self.plain(html)
      doc = Nokogiri::HTML.parse(html)
      doc.text.gsub(/\s+/, " ").strip
    end
  end
end
