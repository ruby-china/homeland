module PagesHelper
  def page_title_tag(page)
    return '' if page.blank?
    link_to(page.title, page_path(page.slug), class: 'page')
  end

  def render_page_version(page)
    page.version
  end

  def render_page_updated_at(page)
    timeago(page.updated_at)
  end

  def render_edit_page_button(page)
    link_to(icon_tag('pencil'), edit_page_path(page))
  end
end
