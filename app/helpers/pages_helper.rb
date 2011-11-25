module PagesHelper
  def page_title_tag(page)
    return "" if page.blank?
    raw "<a href='#{page_path(page.slug)}' class='page'>#{h(page.title)}</a>"
  end
  
  def render_page_version(page)
    page.version
  end
  
  def render_page_updated_at(page)
    timeago(page.updated_at)
  end
  
  def render_edit_page_button(page)
    link_to("编辑", edit_page_path(page), :class => "label success")
  end
end
