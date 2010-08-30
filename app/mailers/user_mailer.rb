class UserMailer < BaseMailer  
  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => "欢迎加入#{APP_CONFIG['app_name']}社区")
  end
end
