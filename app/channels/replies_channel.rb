class RepliesChannel < ApplicationCable::Channel
  def follow(data)
    stop_all_streams
    stream_from "topics/#{data['topic_id']}/replies"
  end

  def unfollow
    stop_all_streams
  end
end
