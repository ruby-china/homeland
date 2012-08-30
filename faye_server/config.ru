require 'faye'
Faye::WebSocket.load_adapter('thin')
# change you access token
ENV["FAYE_ACCESS_TOKEN"] ||= "123456"

app = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
class FayeAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message["data"]
        if message["data"]['token'] != ENV["FAYE_ACCESS_TOKEN"]
          # Setting any 'error' against the message causes Faye to not accept it.
          message['error'] = "Faye authorize faild."
        else
          message.delete('token')
        end
      end
    end
    callback.call(message)
  end
end
app.add_extension(FayeAuth.new)

run app