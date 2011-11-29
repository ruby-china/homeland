# sample code in Redcarpet's repo
class HTMLwithSyntaxHighlight < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, :lexer => language)
  end
end

html_renderer = HTMLwithSyntaxHighlight.new({
  :filter_html => true   # filter out html tags
})

$markdown = Redcarpet::Markdown.new(html_renderer, {
  :autolink => true,
  :fenced_code_blocks => true
})
