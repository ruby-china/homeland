# frozen_string_literal: true

# Backward compatible to support RailsSettingsCached 0.x scoped settings
module ScopedSetting
  extend ActiveSupport::Concern

  included do
    has_many :settings, as: :thing
  end

  class_methods do
    def scoped_field(name, default: nil)
      define_method(name) do
        obj = settings.where(var: name).take || settings.new(var: name, value: default)
        obj.value
      end

      define_method("#{name}=") do |val|
        record = settings.where(var: name).take || settings.new(var: name)
        record.value = val
        record.save!

        val
      end
    end
  end
end
