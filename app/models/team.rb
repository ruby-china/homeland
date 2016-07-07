class Team < User
  has_many :team_users
  has_many :users, through: :team_users

  %i(topics replies notes).each do |key|
    has_many key, through: :users, source: key
  end

  attr_accessor :owner_id
  after_create do
    self.team_users.create(user_id: owner_id, role: :owner) if self.owner_id.present?
  end

  def user_ids
    @user_ids ||= self.users.pluck(:id)
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
