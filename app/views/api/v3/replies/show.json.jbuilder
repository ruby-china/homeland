# frozen_string_literal: true

json.reply do
  json.partial! partial: "reply", locals: {reply: @reply, detail: true}
end
json.meta @meta
