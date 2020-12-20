# frozen_string_literal: true

class User
  # 用户对话题的动作
  module Scores
    extend ActiveSupport::Concern

    included do
    end

    def current_score
      Grade::ScoreService.current_score(self.id)
    end

    def score_logs
      Grade::ScoreService.score_logs(self.id)
    end

    def change_score(action)
      Grade::ScoreService.change_score(self.id, action)
    end
  end
end
