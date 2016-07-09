class TeamUser < ApplicationRecord
  enum role: %i(owner member)
  enum status: %i(pendding accepted)

  belongs_to :team, touch: true
  belongs_to :user

  validates :login, :team_id, :role, presence: true, on: :invite
  validates :user_id, uniqueness: { scope: :team_id, message: I18n.t('teams.user_existed') }

  attr_accessor :login

  before_validation do
    if login.present?
      u = User.find_login(login)
      self.errors.add(:login, :notfound) if u.blank?
      self.user_id = u&.id
    end
  end

  def status_name
    I18n.t("team_user_status.#{self.status}")
  end

  def role_name
    I18n.t("team_user_role.#{self.role}")
  end
end
