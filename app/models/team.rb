# frozen_string_literal: true

class Team < User
  has_one :profile, foreign_key: :user_id, dependent: :nullify
  has_many :replies, foreign_key: :user_id
  has_many :authorizations, foreign_key: :user_id
  has_many :notifications, foreign_key: :user_id
  has_one :sso, class_name: "UserSSO", foreign_key: :user_id, dependent: :destroy

  has_many :team_users
  has_many :users, through: :team_users

  has_many :topics

  attr_accessor :owner_id
  after_create do
    team_users.create(user_id: owner_id, role: :owner, status: :accepted) if owner_id.present?
  end

  def user_ids
    @user_ids ||= users.pluck(:id)
  end

  def password_required?
    false
  end

  def owner?(user)
    team_users.accepted.exists?(role: :owner, user_id: user.id)
  end
end
