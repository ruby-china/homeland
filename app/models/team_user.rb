class TeamUser < ApplicationRecord
  enum role: %i(owner member)

  belongs_to :team
  belongs_to :user
end
