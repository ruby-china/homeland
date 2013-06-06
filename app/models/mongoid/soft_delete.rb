# coding: utf-8
# 软删除
module Mongoid
  module SoftDelete
    extend ActiveSupport::Concern

    included do
      field :deleted_at, type: DateTime

      default_scope where(deleted_at: nil)
      alias_method :destroy!, :destroy
    end

    def destroy
      if persisted?
        self.set(deleted_at: Time.now.utc)
        self.set(updated_at: Time.now.utc)
      end

      @destroyed = true
      freeze
    end
  end
end
