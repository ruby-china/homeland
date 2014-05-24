# config/initializers/will_paginate.rb
module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options[:version] ||= :bootstrap3
      if options[:version] == :bootstrap3
        options[:renderer] ||= BootstrapLinkRenderer3
      else
        options[:renderer] ||= BootstrapLinkRenderer2
      end
      options.delete(:version)
      super.try :html_safe
    end
 
    class BootstrapLinkRenderer2 < LinkRenderer
      protected
 
      def html_container(html)
        tag :div, tag(:ul, html), container_attributes
      end
 
      def page_number(page)
        tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
      end
 
      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
      end
 
      def gap
        tag :li, link(super, '#'), :class => 'disabled'
      end
    end
 
    class BootstrapLinkRenderer3 < BootstrapLinkRenderer2
      protected
 
      def html_container(html)
        tag :ul, html, container_attributes
      end
    end
  end
end

