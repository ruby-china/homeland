class Authorization < ActiveRecord::Base

  validates :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }
end
