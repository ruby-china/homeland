# 异常通知
module ExceptionNotifier
  class DatabaseNotifier
    def initialize(_options)
      # do something with the options...
    end

    def call(exception, _options = {})
      # send the notification
      @title = exception.message
      messages = []
      messages << exception.inspect
      messages << "\n"
      messages << "--------------------------------------------------"
      messages << headers_for_env(_options[:env])
      messages << "--------------------------------------------------"
      unless exception.backtrace.blank?
        messages << "\n"
        messages << exception.backtrace
      end

      if Rails.env.production?
        ExceptionLog.create(title: @title, body: messages.join("\n"))
      end
    end

    def headers_for_env(env)
      return '' if env.blank?

      headers = []
      headers << "Method:     #{env['REQUEST_METHOD']}"
      headers << "URL:        #{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
      headers << "User-Agent: #{env['HTTP_USER_AGENT']}"
      headers << "Language:   #{env['HTTP_ACCEPT_LANGUAGE']}"
      headers << "Server:     #{Socket.gethostname}"
      headers << "Process:    #{$$}"

      headers.join("\n")
    end
  end
end
