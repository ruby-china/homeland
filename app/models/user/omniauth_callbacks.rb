# coding: utf-8  
class User
  module OmniauthCallbacks
     
    def find_or_create_for_github(response)
      provider = response["provider"]
      uid = response["uid"]
      data = response["info"]
      
      if user = User.where("authorizations.provider" => provider , "authorizations.uid" => uid).first
        user
      elsif user = User.find_by_email(data["email"])
        user.bind_service(response)
        user
      else # Create a user with a stub password. 
        user = User.new(:email => data["email"],
          :password => Devise.friendly_token[0,20],
          :location => data["location"],
          :tagline => data["description"],
          :login => data["nickname"]
        )
        if user.save(:validate => false)
          user.authorizations << Authorization.new(:provider => provider, :uid => uid )
          return user
        else
          Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
          return nil
        end
      end
    end
    
    def find_or_create_for_twitter(response)
      provider = response["provider"]
      uid = response["uid"]
      data = response["info"]
      
      if user = User.where("authorizations.provider" => provider , "authorizations.uid" => uid).first
        user
      elsif user = User.find_by_email(data["email"])
        user.bind_service(response)
        user
      else # Create a user with a stub password. 
        user = User.new(:email => "twitter+#{uid}@example.com", 
          :password => Devise.friendly_token[0,20],
          :location => data["location"],
          :tagline => data["description"],
          :login => data["nickname"]
        ) #
        if user.save(:validate => false)
          user.authorizations << Authorization.new(:provider => provider, :uid => uid )
          return user
        else
          Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
          return nil
        end
      end
    end
    
    def find_or_create_for_douban(response)
      provider = response["provider"]
      uid = response["uid"]
      data = response["info"]
      
      if user = User.where("authorizations.provider" => provider , "authorizations.uid" => uid).first
        user
      elsif user = User.find_by_email(data["email"])
        user.bind_service(response)
        user
      else # Create a user with a stub password. 
        user = User.new(:email => "douban+#{uid}@example.com",
          :password => Devise.friendly_token[0,20],
          :location => data["location"],
          :tagline => data["description"],
          :login => data["nickname"]
        ) #
        if user.save(:validate => false)
          user.authorizations << Authorization.new(:provider => provider, :uid => uid )
          return user
        else
          Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
          return nil
        end
      end
    end
    
    def find_or_create_for_google(response)
      provider = response["provider"]
      uid = response["uid"]
      data = response["info"]
      
      if user = User.where("authorizations.provider" => provider , "authorizations.uid" => uid).first
        user
      elsif user = User.find_by_email(data["email"])
        user.bind_service(response)
        user
      else # Create a user with a stub password. 
        user = User.new(:email => data["email"],
          :password => Devise.friendly_token[0,20],
          :location => data["location"],
          :tagline => data["description"],
          :login => data["name"]
        ) #
        if user.save(:validate => false)
          user.authorizations << Authorization.new(:provider => provider, :uid => uid )
          return user
        else
          Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
          return nil
        end
      end
    end
    
    
  end
end