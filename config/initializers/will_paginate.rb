module WillPaginate
  module ActionView
    def will_paginate1(collection = nil, options = {})
      options[:renderer] ||= BootstrapLinkRenderer
      super.try :html_safe
    end
  end
end