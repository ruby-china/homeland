class Device < ApplicationRecord
  belongs_to :user

  enum platform: %i[ios android]

  validates :platform, :token, presence: true
  validates :token, uniqueness: { scope: %i[user_id platform] }

  def alive?
    return true if last_actived_at.blank?
    (Date.current - last_actived_at.to_date).to_i <= 14
  end

  def platform_name
    @platform_name ||= I18n.t "device_platform.#{self.platform}"
  end
end
