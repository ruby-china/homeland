# coding: utf-8
module PagesHelper
  def page_title_tag(page)
    return "" if page.blank?
    link_to(page.title, page_path(page.slug), :class => "page")
  end

  def render_page_version(page)
    page.version
  end

  def render_page_updated_at(page)
    timeago(page.updated_at)
  end

  def render_edit_page_button(page)
    link_to("", edit_page_path(page), :class => "icon small_edit")
  end
end
