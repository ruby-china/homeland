# Add a fake second_level_cache method to the model for compatibility with the Homeland plugins.
module FakeSecondCache
  extend ActiveSupport::Concern

  class_methods do
    def second_level_cache(args = {})
    end
  end
end
