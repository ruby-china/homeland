class User < ActiveRecord::Base
  module OmniauthCallbacks
    def find_from_hash(hash)
      where("authorizations.provider" => hash['provider'], "authorizations.uid" => hash['uid']).first
    end

    def create_from_hash(auth)  
      Rails.logger.debug(auth)
      user = User.new
      user.login = auth["user_info"]["nickname"] || auth["user_info"]["username"]
      user.login.gsub!(/[^\w]/, '_')
      user.login.slice!(0, 20)
      if User.where(:login => user.login).count > 0 or user.login.blank?
        user.login = "u#{Time.now.to_i}"
      end
      user.email = auth['user_info']['email']
      user.location = auth['user_info']['location']
      user.tagline =  auth["user_info"]["description"]
      if not auth["user_info"]["urls"].blank?
        url_hash = auth["user_info"]["urls"].first
        user.website = url_hash.last
      end
      if user.save(:validate => false)
        user.authorizations << Authorization.new(:provider => auth['provider'], :uid => auth['uid'])
        return user
      else
        Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
        return nil
      end
    end
  end
end