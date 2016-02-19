class Device < ApplicationRecord
  belongs_to :user

  enum kind: %i(ios android)

  validates :kind, :token, presence: true
  validates :token, uniqueness: { scope: [:user_id, :kind] }

  def alive?
    return true if last_actived_at.blank?
    (Date.current - last_actived_at.to_date).to_i <= 14
  end
end
