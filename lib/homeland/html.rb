module Homeland
  class Html
    PLAIN_REGEXP = /<.+?>/

    def self.plain(html)
      html.gsub(PLAIN_REGEXP, " ")
    end
  end
end
