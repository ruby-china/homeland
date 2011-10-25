# coding: utf-8
class WatchMailer < ActionMailer::Base
  def receive(mail)
    Rails.logger.info(">>>>>>>>>> #{mail.inspect}")
    
    mail.extend(ReceivedMail)
    mail.create_topic
  rescue => e
    puts ">>>>>>>>>>>>>>>>> WatchMailer receive failed: #{e}#{e.backtrace}"
  end
end
