html_renderer = Redcarpet::Render::HTML.new({
  :filter_html => true   # filter out html tags
})

$markdown = Redcarpet::Markdown.new(html_renderer, {
  :autolink => true,
  :fenced_code_blocks => true
})
