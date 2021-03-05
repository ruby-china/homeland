# frozen_string_literal: true

json.topic do
  json.partial! partial: "topic", locals: {topic: @topic, detail: true}
end
json.meta @meta
