# coding: utf-8  
class UserMailer < BaseMailer  
  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => "欢迎加入#{Setting.app_name}社区")
  end
  
  class Preview < MailView
    # Pull data from existing fixtures
    def welcome
      ::UserMailer.welcome(User.first)
    end
  end
end
