#require 'openid/store/filesystem'
#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :twitter, Setting.twitter_token, Setting.twitter_secret
#  provider :github, Setting.github_token, Setting.github_secret
#  provider :douban, Setting.douban_token, Setting.douban_secret
#  provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
#end
