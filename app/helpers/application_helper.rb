# coding: utf-8  
require "bluecloth"
module ApplicationHelper
  # return the formatted flash[:notice] html
  def notice_message()
    if flash[:notice]
      result = '<div class="alert-message success"><a href="#" class="close">x</a>'+flash[:notice]+'</div>'
    elsif flash[:warring]
        result = '<div class="alert-message warring"><a href="#" class="close">x</a>'+flash[:warring]+'</div>'
    elsif flash[:alert]
        result = '<div class="alert-message alert"><a href="#" class="close">x</a>'+flash[:alert]+'</div>'
    elsif flash[:error]
        result = '<div class="alert-message error"><a href="#" class="close">x</a>'+flash[:error]+'</div>'
    else
      result = ''
    end
    
    return raw(result)
  end
  
  def markdown(str)
    raw "<div class=\"markdown_content\">#{BlueCloth.new(str).to_html}</div>"
  end
  
  def admin?(user = nil)
    return false if user.blank?
    return true if Setting.admin_emails.include?(user.email)
    return false
  end
  
  def owner?(item)
    return false if item.blank?
    return if current_user.blank?
    item.user_id == current_user.id
  end
  
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
  
  class BootstrapLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
    protected
    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class =>
('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'), :class => [classname[0..3],
classname, ('disabled' unless page)].join(' ')
    end
  end

  def will_paginate1(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2,
:outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label =>
'上一页'.html_safe, :next_label => '下一页'.html_safe)
  end
end
