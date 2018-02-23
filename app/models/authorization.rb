# frozen_string_literal: true

class Authorization < ApplicationRecord
  belongs_to :user
  validates :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }
end
