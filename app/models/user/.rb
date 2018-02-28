# frozen_string_literal: true

class User
  module UserCallbacks
    extend ActiveSupport::Concern

    included do
      after_commit :send_welcome_mail, on: :create
      before_save :store_location
    end

    def send_welcome_mail
      UserMailer.welcome(id).deliver_later
    end

    # Store user location
    def store_location
      if self.location_changed?
        if location.blank?
          self.location_id = nil
        else
          old_location = Location.location_find_by_name(self.location_was)
          old_location&.decrement!(:users_count)

          location = Location.location_find_or_create_by_name(self.location)
          unless location.new_record?
            location.increment!(:users_count)
            self.location_id = location.id
          end
        end
      end
    end
  end
end
