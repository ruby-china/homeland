json.replies @replies do |reply|
  json.partial! partial: 'reply', locals: { reply: reply, detail: true }
end
