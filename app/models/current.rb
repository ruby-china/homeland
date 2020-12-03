# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :request_id
  attribute :user
end
