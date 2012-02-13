module SearchHelper
  def search_result_highlight(hit, key)
    raw hit.highlights(key).collect { |t| t.format { |t1| content_tag(:span, t1, :class => "highlight") } }.join("")
  end
end
