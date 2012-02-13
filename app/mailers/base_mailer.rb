# coding: utf-8
require "resque"
class BaseMailer < ActionMailer::Base
  default :from => Setting.email_sender
  default :charset => "utf-8"
  default :content_type => "text/html"
  default_url_options[:host] = Setting.domain
  include Resque::Mailer

  layout 'mailer'
  helper :topics, :users
end
