module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(deleted_at: nil) }

    alias_method :destroy!, :destroy
  end

  def destroy
    run_callbacks(:destroy) do
      if persisted?
        set(deleted_at: Time.now.utc)
        set(updated_at: Time.now.utc)
      end

      @destroyed = true
    end
    freeze
  end

  def deleted?
    deleted_at.present?
  end
end
