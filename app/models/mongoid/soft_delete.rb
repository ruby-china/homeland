# coding: utf-8
# 软删除
module Mongoid
  module SoftDelete      
    extend ActiveSupport::Concern
  
    def self.included(base)
      base.instance_eval do
        field :deleted_at, :type => DateTime
      
        default_scope where(:deleted_at => nil)
        alias_method :destroy!, :destroy

        include InstanceMethods
      end
    end
  
    module InstanceMethods
      def destroy
        if persisted?
          self.update_attribute(:deleted_at,Time.now.utc)
        end

        @destroyed = true
        freeze
      end
    end
  end
end