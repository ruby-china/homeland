# coding: utf-8
require 'rdiscount'
module ApplicationHelper

  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type == :notice
      flash_messages << "<div class=\"alert-message #{type}\"><a href=\"#\" class=\"close\">x</a>#{message}</div>" if message
    end

    flash_messages.join("\n").html_safe
  end

  def markdown(str)
    content_tag(:div,RDiscount.new(str).to_html, :class => "wikistyle" )
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

  class BootstrapLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
    protected
    def html_container(html)
      tag(:div, tag(:ul, html), container_attributes)
    end

    def page_number(page)
      tag( :li, link(page, page, :rel => rel_value(page)), :class =>
('active' if page == current_page))
    end

    def gap
      tag(:li, link(super, '#'), :class => 'disabled')
    end

    def previous_or_next_page(page, text, classname)
      tag( :li, link(text, page || '#'), :class => [classname[0..3],
classname, ('disabled' unless page)].join(' '))
    end
  end

  def will_paginate1(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2,
:outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label =>
'上一页'.html_safe, :next_label => '下一页'.html_safe)
  end

  
end
