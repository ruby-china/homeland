require 'net/imap'
# add plain as an authentication type...
# This is taken from:
# http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/lib/net/imap.rb?revision=7657&view=markup&pathrev=10966

# Authenticator for the "PLAIN" authentication type.  See
# #authenticate().
class PlainAuthenticator
  def process(data)
    return "\0#{@user}\0#{@password}"
  end

  private

  def initialize(user, password)
    @user = user
    @password = password
  end
end

Net::IMAP.add_authenticator "PLAIN", PlainAuthenticator