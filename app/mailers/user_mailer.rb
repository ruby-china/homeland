# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome(user_id)
    @user = User.find_by_id(user_id)
    return false if @user.blank?
    mail(to: @user.email, subject: t("mail.welcome_subject", app_name: Setting.app_name).to_s)
  end
end
