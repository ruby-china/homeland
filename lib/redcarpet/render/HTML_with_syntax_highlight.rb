# coding: utf-8
require 'rails'
require 'rails_autolink'
require 'redcarpet'
require 'singleton'
require 'md_emoji'
require 'rouge'
require 'rouge/plugins/redcarpet'

module Redcarpet
  module Render
    class HTMLwithSyntaxHighlight < HTML
      include Rouge::Plugins::Redcarpet

      def initialize(extensions={})
        super(extensions.merge(:xhtml => true,
                               :no_styles => true,
                               :filter_html => true,
                               :hard_wrap => true))
      end


      def block_code(code, language)
        language.downcase! if language.is_a?(String)
        html = super(code, language)
        # 将最后行的 "\n\n" 替换成回 "\n", rouge 0.3.2 的 Bug 导致
        html.gsub!("\n</pre>", "</pre>")
        html
      end

      def autolink(link, link_type)
        # return link
        if link_type.to_s == "email"
          link
        else
          begin
            # 防止 C 的 autolink 出来的内容有编码错误，万一有就直接跳过转换
            # 比如这句:
            # 此版本并非线上的http://yavaeye.com的源码.
            link.match(/.+?/)
          rescue
            return link
          end
          # Fix Chinese neer the URL
          bad_text = link.match(/[^\w:\/\-\~\,\$\!\.=\?&#+\|\%]+/im).to_s
          link.gsub!(bad_text, '')
          "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\">#{link}</a>#{bad_text}"
        end
      end
    end
  end
end
