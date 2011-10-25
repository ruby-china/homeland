require File.dirname(__FILE__) + '/../vendor/secure_pop'

module Fetcher
  class Pop < Base

    protected
    
    # Additional Options:
    # * <tt>:ssl</tt> - whether or not to use ssl encryption
    # * <tt>:port</tt> - port to use (defaults to 110)
    def initialize(options={})
      @ssl = options.delete(:ssl)
      @port = options.delete(:port) || Net::POP3.default_port
      super(options)
    end
    
    # Open connection and login to server
    def establish_connection
      @connection = Net::POP3.new(@server, @port)
      @connection.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if @ssl
      @connection.start(@username, @password)
    end
    
    # Retrieve messages from server
    def get_messages
      unless @connection.mails.empty?
        @connection.each_mail do |msg|
          begin
            process_message(msg.pop)
          rescue
            handle_bogus_message(msg.pop)
          end
          # Delete message from server
          msg.delete
        end
      end
    end
    
    # Store the message for inspection if the receiver errors
    def handle_bogus_message(message)
      # This needs a good solution
    end
    
    # Close connection to server
    def close_connection
      @connection.finish
    end
    
  end
end
