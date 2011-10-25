require 'socket'
require 'net/pop'
require 'net/protocol'
require 'openssl/ssl'

# Backport of ruby 1.9's POP3 SSL support
class Net::POP3
  @@usessl = nil
  @@verify = nil
  @@certs = nil
  PORT = 110
  SSL_PORT = 995
  
  def self.default_port
    PORT
  end
  
  def self.default_ssl_port
    SSL_PORT
  end
  
  # Enable SSL for all new instances.
  # +verify+ is the type of verification to do on the Server Cert; Defaults
  # to OpenSSL::SSL::VERIFY_PEER.
  # +certs+ is a file or directory holding CA certs to use to verify the 
  # server cert; Defaults to nil.
  def self.enable_ssl( verify = OpenSSL::SSL::VERIFY_PEER, certs = nil )
    @@usessl = true
    @@verify = verify
    @@certs = certs  
  end
  
  # Disable SSL for all new instances.
  def self.disable_ssl
    @@usessl = nil
    @@verify = nil
    @@certs = nil
  end
  
  # Creates a new POP3 object.
  # +addr+ is the hostname or ip address of your POP3 server.
  # The optional +port+ is the port to connect to.
  # The optional +isapop+ specifies whether this connection is going
  # to use APOP authentication; it defaults to +false+.
  # This method does *not* open the TCP connection.
  def initialize(addr, port = nil, isapop = false)
    @address = addr
    @usessl = @@usessl
    if @usessl
      @port = port || SSL_PORT
    else
      @port = port || PORT
    end
    @apop = isapop
    
    @certs = @@certs
    @verify = @@verify
    
    @command = nil
    @socket = nil
    @started = false
    @open_timeout = 30
    @read_timeout = 60
    @debug_output = nil

    @mails = nil
    @n_mails = nil
    @n_bytes = nil
  end
  
  # does this instance use SSL?
  def usessl?
    @usessl
  end
  
  # Enables SSL for this instance.  Must be called before the connection is
  # established to have any effect.
  # +verify+ is the type of verification to do on the Server Cert; Defaults
  # to OpenSSL::SSL::VERIFY_PEER.
  # +certs+ is a file or directory holding CA certs to use to verify the 
  # server cert; Defaults to nil.
  # +port+ is port to establish the SSL conection on; Defaults to 995.
  def enable_ssl(verify = OpenSSL::SSL::VERIFY_PEER, certs = nil, 
                 port = SSL_PORT)
    @usessl = true
    @verify = verify
    @certs = certs
    @port = port
  end
  
  def disable_ssl
    @usessl = nil
    @verify = nil
    @certs = nil
  end
  
  def do_start( account, password )
    s = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    if @usessl
      unless defined?(OpenSSL)
        raise "SSL extension not installed"
      end
      sslctx = OpenSSL::SSL::SSLContext.new
      sslctx.verify_mode = @verify
      sslctx.ca_file = @certs if @certs && FileTest::file?(@certs)
      sslctx.ca_path = @certs if @certs && FileTest::directory?(@certs)
      s = OpenSSL::SSL::SSLSocket.new(s, sslctx)
      s.sync_close = true
      s.connect
    end
    
    @socket = Net::InternetMessageIO.new(s)
    on_connect
    @command = Net::POP3Command.new(@socket)
    if apop?
      @command.apop account, password
    else
      @command.auth account, password
    end
    @started = true
  ensure
    do_finish if not @started
  end
  private :do_start
end
