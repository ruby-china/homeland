# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout "mailer"
  helper :topics, :users

  # Mailer default options will update by lib/homeland/setup_mailer.rb in Rails runtime.
  # This line just for work with Test case.
  default from: Setting.mailer_sender

  rescue_from Postmark::InactiveRecipientError do |exception|
    # do nothing
  end
end
