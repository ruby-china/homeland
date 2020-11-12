module HotnessScore
  extend ActiveSupport::Concern

  included do
    after_commit :async_calc_score, on: %i[create update]
  end

  def async_calc_score
    CalculateScoreJob.perform_later(self.class.name, self.id)
  end
end
