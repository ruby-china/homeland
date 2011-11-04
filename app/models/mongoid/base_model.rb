# coding: utf-8
# 基本 Model，加入一些通用功能
module Mongoid
  module BaseModel      
    extend ActiveSupport::Concern
    
    def self.included(base)
      base.instance_eval do
        scope :recent, desc(:_id)
        scope :exclude_ids, Proc.new { |ids| where(:_id.nin => ids.collect { |id| id.to_i }) }
      end
    end
    
    module ClassMethods
      # like ActiveRecord find_by_id
      def find_by_id(id)
        where(:_id => id.to_i).first
      end
    end
  end
end