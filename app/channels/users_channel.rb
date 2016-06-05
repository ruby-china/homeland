# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class UsersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "all"
    ActionCable.server.broadcast("all", count: ActionCable.server.connections.length)
  end

  def unsubscribed
    ActionCable.server.broadcast("all", count: ActionCable.server.connections.length)
  end
end
