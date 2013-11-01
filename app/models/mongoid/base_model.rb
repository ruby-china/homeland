# coding: utf-8
# 基本 Model，加入一些通用功能
module Mongoid
  module BaseModel
    extend ActiveSupport::Concern

    included do
      scope :recent, desc(:_id)
      scope :exclude_ids, lambda { |ids| where(:_id.nin => ids.map(&:to_i)) }
      scope :by_week, where(:created_at.gte => 7.days.ago.utc)
      
      delegate :url_helpers, to: 'Rails.application.routes' 
    end

    module ClassMethods
      # like ActiveRecord find_by_id
      def find_by_id(id)
        if id.is_a?(Integer) or id.is_a?(String)
          where(:_id => id.to_i).first
        else
          nil
        end
      end

      def find_in_batches(opts = {})
        batch_size = opts[:batch_size] || 1000
        start = opts.delete(:start).to_i || 0
        objects = self.limit(batch_size).skip(start)
        t = Time.new
        while objects.any?
          yield objects
          start += batch_size
          # Rails.logger.debug("processed #{start} records in #{Time.new - t} seconds") if Rails.logger.debug?
          break if objects.size < batch_size
          objects = self.limit(batch_size).skip(start)
        end
      end

      def delay
        Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
      end
    end

    def delay
      Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
    end
  end
end
