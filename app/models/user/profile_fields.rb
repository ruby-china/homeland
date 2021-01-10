# frozen_string_literal: true

class User
  module ProfileFields
    extend ActiveSupport::Concern

    included do
      delegate :contacts, to: :profile, allow_nil: true
      delegate :theme, to: :profile, allow_nil: true

      before_save :store_location
    end

    def profile_field(field)
      return nil if contacts.nil?
      contacts[field.to_sym]
    end

    def full_profile_field(field)
      v = profile_field(field)
      prefix = Profile.contact_field_prefix(field)
      return v if prefix.blank?
      [prefix, v].join("")
    end

    def update_theme(value)
      self.create_profile if self.profile.blank?
      self.profile.update(theme: value)
    end

    def update_profile_fields(field_values)
      val = contacts || {}
      field_values.each do |key, value|
        next unless Profile.has_field?(key)
        val[key.to_sym] = value
      end

      self.create_profile if self.profile.blank?
      self.profile.update(contacts: val)
    end

    private
      # Store user location into Location
      def store_location
        return if !self.location_changed?

        if location.blank?
          self.location_id = nil
          return
        end

        old_location = Location.location_find_by_name(self.location_was)
        old_location&.decrement!(:users_count)

        location = Location.location_find_or_create_by_name(self.location)
        if !location.new_record?
          location.increment!(:users_count)
          self.location_id = location.id
        end
      end
  end
end
