# Countable for storage by use ActiveRecord
module Countable
  extend ActiveSupport::Concern

  included do
    scope :with_counters, -> { includes(@@countable_names) }
  end

  class_methods do
    def countable(*names)
      class_eval do
        @@countable_names ||= []

        names.each do |name|
          @@countable_names << "#{name}_counter".to_sym
          has_one :"#{name}_counter", -> { where(key: name) }, as: :countable, class_name: "Counter"

          define_method :"#{name}" do
            send(:"#{name}_counter") || send(:"create_#{name}_counter")
          end
        end
      end
    end
  end
end
