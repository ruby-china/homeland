require 'redcarpet'
require 'rouge/plugins/redcarpet'
require 'nokogiri'

module Homeland
  class Pipeline
    class MarkdownFilter < HTML::Pipeline::TextFilter
      DEFAULT_OPTIONS = {
        no_styles: true,
        hard_wrap: true,
        autolink: true,
        fenced_code_blocks: true,
        strikethrough: true,
        underline: true,
        superscript: true,
        tables: true,
        footnotes: true,
        lax_spacing: true,
        space_after_headers: true,
        disable_indented_code_blocks: true,
        no_intra_emphasis: true
      }

      def call
        html = Render.to_html(@text)
        html.strip!
        html
      end

      class Render < Redcarpet::Render::HTML
        include Rouge::Plugins::Redcarpet

        class << self
          def to_html(raw)
            @@render ||= Redcarpet::Markdown.new(self.new, DEFAULT_OPTIONS)
            @@render.render(raw)
          end
        end

        def block_code(code, lang)
          lang.downcase! if lang.is_a?(String)
          code = code.strip_heredoc
          super(code, lang)
        end

        def table(header, body)
          %(<div class="table-responsive"><table class="table table-bordered table-striped">#{header}#{body}</table></div>)
        end

        def header(text, header_level)
          l = header_level <= 2 ? 2 : header_level
          raw_text = Nokogiri::HTML(text).xpath('//text()')
          %(<h#{l} id="#{raw_text}">#{text}</h#{l}>)
        end

        # Extend to support img width
        # ![](foo.jpg =300x)
        # ![](foo.jpg =300x200)
        # Example: https://gist.github.com/uupaa/f77d2bcf4dc7a294d109
        def image(link, title, alt_text)
          links = link.split(' ')
          link = links[0]
          if links.count > 1
            # 原本 Markdown 的 title 部分是需要引号的 ![](foo.jpg "Title")
            # ![](foo.jpg =300x)
            title = links[1]
          end

          if title =~ /=(\d+)x(\d+)/
            %(<img src="#{link}" width="#{Regexp.last_match(1)}px" height="#{Regexp.last_match(2)}px" alt="#{alt_text}">)
          elsif title =~ /=(\d+)x/
            %(<img src="#{link}" width="#{Regexp.last_match(1)}px" alt="#{alt_text}">)
          elsif title =~ /=x(\d+)/
            %(<img src="#{link}" height="#{Regexp.last_match(1)}px" alt="#{alt_text}">)
          else
            %(<img src="#{link}" title="#{title}" alt="#{alt_text}">)
          end
        end

        # Fix Chinese neer the URL
        def autolink(link, link_type)
          # return link
          if link_type.to_s == 'email'
            link
          else
            begin
              # 防止 C 的 autolink 出来的内容有编码错误，万一有就直接跳过转换
              # 比如这句: 此版本并非线上的http://yavaeye.com的源码.
              link.match(/.+?/)
            rescue
              return link
            end
            # Fix Chinese neer the URL
            bad_text = link.match(%r{[^\w:@/\-~,$!.=?&#+|%]+}im).to_s
            link.gsub!(bad_text, '')
            %(<a href="#{link}" rel="nofollow" target="_blank">#{link}</a>#{bad_text})
          end
        end
      end # end RenderHTML
    end
  end
end
