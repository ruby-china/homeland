module Homeland
  class << self
    def version
      '2.4.0.beta'
    end

    def file_store
      @file_store ||= ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache'))
    end
  end
end