# frozen_string_literal: true

class User
  module SoftDelete
    extend ActiveSupport::Concern

    included do
      define_callbacks :soft_delete
    end

    def soft_delete
      run_callbacks :soft_delete do
        self.state = "deleted"
        save(validate: false)
      end
    end
  end
end
