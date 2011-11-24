# coding: utf-8  
require 'rdiscount'
module ApplicationHelper
  # return the formatted flash[:notice] html
  def notice_message()
    if flash[:notice]
      result = '<div class="alert-message success"><a href="#" class="close">x</a>'+flash[:notice]+'</div>'
    elsif flash[:warning]
        result = '<div class="alert-message warning"><a href="#" class="close">x</a>'+flash[:warning]+'</div>'
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
    raw "<div class=\"wikistyle\">#{RDiscount.new(str).to_html}</div>"
  end
  
  def admin?(user = nil)
    user = current_user if user.blank?
    return false if user.blank?
    return true if user.admin?
    return false
  end
  
  def wiki_editor?(user = nil)
    user = current_user if user.blank?
    return false if user.blank?
    return true if user.wiki_editor?
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
  
  def share_tag(title)
    html = <<-eos
    <div class='share_buttons' data-title="#{title}">
      <a href="#" rel="nofollow" rel="twipsy" data-site="twitter" class="icon share_icons_twitter" title="转发到Twitter"></a>
      <a href="#" rel="nofollow" rel="twipsy" data-site="weibo" class="icon share_icons_weibo" title="转发到新浪微博"></a>
      <a href="#" rel="nofollow" rel="twipsy" data-site="douban" class="icon share_icons_douban" title="转发到豆瓣"></a>
    </div>
    eos
    raw html
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
