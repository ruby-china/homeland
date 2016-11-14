module Homeland
  class << self
    def version
      '2.3.0.rc'
    end

    def file_store
      @file_store ||= ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache'))
    end
  end
end