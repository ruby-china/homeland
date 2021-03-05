# frozen_string_literal: true

json.node do
  json.partial! partial: "node", locals: {node: @node}
end
json.meta @meta
