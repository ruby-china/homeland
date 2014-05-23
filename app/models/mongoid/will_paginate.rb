# coding: utf-8
require 'will_paginate'
require 'will_paginate/collection'

module Mongoid
  module WillPaginate
    extend ActiveSupport::Concern

    def paginate(options = {})
      options = base_options options

      ::WillPaginate::Collection.create(options[:page], options[:per_page]) do |pager|
        items_count = options[:total_entries] || self.count
        fill_pager_with self.skip(options[:offset]).limit(options[:per_page]), items_count, pager
      end
    end

    private

    def base_options(options)
      options[:page] ||= 1
      options[:per_page] ||= 20
      options[:offset] = (options[:page].to_i - 1) * options[:per_page].to_i
      options
    end

    def fill_pager_with(medias, size, pager)
      pager.replace medias.to_a
      pager.total_entries = size
    end
  end
end
