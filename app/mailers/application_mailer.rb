# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout "mailer"
  helper :topics, :users

  # Mailer default options will update by lib/homeland/setup_mailer.rb in Rails runtime.
  # This line just for work with Test case.
  default charset: "utf-8"
  default content_type: "text/html"

  rescue_from Postmark::InactiveRecipientError do |exception|
    # do nothing
  end

  # Override ActionMail mail method for use Setting's mailer options
  # Now, we can change mailer options after Rails booted
  alias_method :super_mail, :mail
  def mail(headers = {}, &block)
    headers[:from] = Setting.mailer_sender
    headers[:delivery_method] = Rails.env.test? ? :test : Setting.mailer_provider.to_sym
    headers[:delivery_method_options] = Setting.mailer_options.deep_symbolize_keys
    super_mail(headers, &block)
  end
end
