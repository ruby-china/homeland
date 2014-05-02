# coding: utf-8
# 异常通知
module ExceptionNotifier
  class DatabaseNotifier
    def initialize(options)
      # do something with the options...
    end

    def call(exception, options={})
      # send the notification
      @title = exception.message
      messages = []
      messages << exception.inspect
      if !exception.backtrace.blank?
        messages << "\n"
        messages << exception.backtrace
      end
      
      if Rails.env.production?
        ExceptionLog.create(title: @title, body: messages.join("\n"))
      else
        puts "\n======================"
        puts messages.join("\n")
        puts "======================\n"
      end
    end
  end
end