# frozen_string_literal: true

class RepliesChannel < ApplicationCable::Channel
  def follow(data)
    stream_from "topics/#{data["topic_id"]}/replies"
  end

  def unfollow
    stop_all_streams
  end
end
