require 'net/http'
class FayeClient
  def self.send(channel, params)
    uri ||= URI.parse("http://#{Setting.domain}/faye")
    params[:token] = Setting.faye_token
    Thread.new {
      message = { :channel => channel, :data => params }
      Net::HTTP.post_form(uri, :message => message.to_json)
    }
  end
end