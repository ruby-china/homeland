html_renderer = Redcarpet::Render::HTML.new({
  :filter_html => true,   # filter out html tags
  :hard_wrap => true      # auto <br> in <p>
})

$markdown = Redcarpet::Markdown.new(html_renderer, {
  :autolink => true,
  :fenced_code_blocks => true
})
