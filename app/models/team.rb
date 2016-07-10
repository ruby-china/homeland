class Team < User
  has_many :team_users
  has_many :users, through: :team_users

  has_many :topics

  attr_accessor :owner_id
  after_create do
    self.team_users.create(user_id: owner_id, role: :owner, status: :accepted) if self.owner_id.present?
  end

  def user_ids
    @user_ids ||= self.users.pluck(:id)
  end

  def password_required?
    false
  end

  def owner?(user)
    self.team_users.accepted.exists?(role: :owner, user_id: user.id)
  end

  def member?(user)
    self.team_users.accepted.exists?(user_id: user.id)
  end
end
