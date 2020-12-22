# frozen_string_literal: true

json.scores @scores do |score|
  json.id score.id
  json.created_at score.created_at.strftime("%F %T")
  json.message score.message
  json.score score.score
  json.change_type score.change_type
  json.after_score score.after_score
end
