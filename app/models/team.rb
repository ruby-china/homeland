class Team < User
  has_many :team_users
  has_many :users, through: :team_users

  attr_accessor :owner_id
  after_create do
    self.team_users.create(user_id: owner_id, role: :owner) if self.owner_id.present?
  end

  def password_required?
    false
  end

  def owner?(user)
    self.team_users.exists?(role: :owner, user_id: user.id)
  end

  def member?(user)
    self.team_users.exists?(user_id: user.id)
  end
end
