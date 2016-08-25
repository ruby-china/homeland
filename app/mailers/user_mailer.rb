class UserMailer < BaseMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: t('mail.welcome_subject', app_name: Setting.app_name).to_s)
  end
end
