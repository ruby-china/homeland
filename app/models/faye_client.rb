require 'net/http'
class FayeClient
  def self.send(channel, params)
    @@client ||= Faye::Client.new(Setting.faye_server)
    params[:token] = Setting.faye_token
    @@client.publish(channel, params)
  end
end