class TeamUser < ApplicationRecord
  enum role: %i(owner member)

  belongs_to :team, touch: true
  belongs_to :user
end
