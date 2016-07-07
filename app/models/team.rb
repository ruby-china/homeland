class Team < User
  has_many :team_users
  has_many :users, through: :team_users

  def password_required?
    false
  end
end
