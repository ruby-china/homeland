class MarkdownConverter
  include Singleton

  class HTMLwithSyntaxHighlight < Redcarpet::Render::HTML
    def block_code(code, language)
     language = 'text' if language.blank?
     begin
       Pygments.highlight(code, :lexer => language, :formatter => 'html', :options => {:encoding => 'utf-8'})
     rescue
       Pygments.highlight(code, :lexer => 'text', :formatter => 'html', :options => {:encoding => 'utf-8'})
     end
    end
  end

  def self.convert(text)
    self.instance.convert(text)
  end

  def convert(text)
    @converter.render(text)
  end

  private
  def initialize
    html_renderer = HTMLwithSyntaxHighlight.new({
      :filter_html => true   # filter out html tags
    })

    @converter = Redcarpet::Markdown.new(html_renderer, {
      :autolink => true,
      :fenced_code_blocks => true
    })
  end
end
