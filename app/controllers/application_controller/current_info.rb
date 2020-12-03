# frozen_string_literal: true

class ApplicationController
  module CurrentInfo
    extend ActiveSupport::Concern

    included do
      before_action do
        Current.request_id = request.uuid
        Current.user = current_user
      end
    end
  end
end
