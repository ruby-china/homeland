class BaseMailer < ActionMailer::Base
  default :from => APP_CONFIG['smtp_username']
  default_url_options[:host] = APP_CONFIG['domain']
  layout 'mailer'
end