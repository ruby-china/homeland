class RepliesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "topics/#{params[:topic_id]}/replies"
  end

  def unsubscribed
  end
end
