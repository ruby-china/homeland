module PagesHelper
  def page_title_tag(page)
    return "" if page.blank?
    raw "<a href='#{page_path(page.slug)}' class='page'>#{h(page.title)}</a>"
  end
end
