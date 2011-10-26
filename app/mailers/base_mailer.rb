# coding: utf-8  
class BaseMailer < ActionMailer::Base
  default :from => Setting.smtp_username
  default_url_options[:host] = Setting.domain
  layout 'mailer'
  helper :topics
end
