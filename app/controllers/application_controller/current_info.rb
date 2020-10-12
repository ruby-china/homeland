# frozen_string_literal: true

class ApplicationController
  module CurrentInfo
    extend ActiveSupport::Concern

    included do
      before_action do
        Current.user = current_user if current_user
      end
    end
  end
end
