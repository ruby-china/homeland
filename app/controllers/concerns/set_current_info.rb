# frozen_string_literal: true

module SetCurrentInfo
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.user = current_user if current_user
    end
  end
end
