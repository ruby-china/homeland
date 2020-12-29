# frozen_string_literal: true

json.user do
  json.partial! partial: "user", locals: { user: @user, detail: true }
  json.score @user.current_score
end
json.meta @meta
