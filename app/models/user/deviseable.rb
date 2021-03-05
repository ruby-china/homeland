# frozen_string_literal: true

class User
  # Omniauth
  module Deviseable
    extend ActiveSupport::Concern

    included do
      attr_accessor :omniauth_provider, :omniauth_uid

      devise :database_authenticatable, :registerable, :recoverable, :lockable,
        :rememberable, :trackable, :validatable, :omniauthable

      after_create :bind_omniauth_on_create

      # Override Devise to send mails with async
      def send_devise_notification(notification, *args)
        devise_mailer.send(notification, self, *args).deliver_later
      end

      # Override Devise password_required?
      def password_required?
        (authorizations.empty? || !password.blank?) && super
      end
    end

    def bind?(provider)
      authorizations.collect(&:provider).include?(provider.to_s)
    end

    def bind_service(response)
      provider = response["provider"]
      uid = response["uid"].to_s

      authorizations.create(provider: provider, uid: uid)
    end

    def bind_omniauth_on_create
      if omniauth_provider
        Authorization.find_or_create_by!(provider: omniauth_provider, uid: omniauth_uid, user_id: id)
      end
    end

    # User who was logined with omniauth but not bind user info (email and password)
    def legacy_omniauth_logined?
      email.include?("@example.com")
    end

    module ClassMethods
      # Use Omniauth callback info to create and bind user
      def find_or_create_by_omniauth(omniauth_auth)
        Authorization.find_user_by_provider(omniauth_auth["provider"], omniauth_auth["uid"])
      end

      def new_from_provider_data(provider, uid, data)
        User.new do |user|
          user.email =
            if data["email"].present? && !User.where(email: data["email"]).exists?
              data["email"]
            else
              "#{provider}+#{uid}@example.com"
            end

          user.name = data["name"]
          user.login = Homeland::Username.sanitize(data["nickname"])

          if provider == "github"
            user.github = data["nickname"]
          end

          if user.login.blank?
            user.login = "u#{Time.now.to_i}"
          end

          if User.where(login: user.login).exists?
            # TODO: possibly duplicated user login here. What should we do?
            user.login = "#{user.github}-github"
          end

          user.password = Devise.friendly_token[0, 20]
          user.location = data["location"]
          user.tagline = data["description"]
        end
      end

      %w[github].each do |provider|
        define_method "find_or_create_for_#{provider}" do |response|
          uid = response["uid"].to_s
          data = response["info"]

          user = Authorization.find_by(provider: provider, uid: uid).try(:user)
          return user if user

          user = User.new_from_provider_data(provider, uid, data)
          if user.save(validate: false)
            Authorization.find_or_create_by(provider: provider, uid: uid, user_id: user.id)
            return user
          end

          Rails.logger.warn("User.create_from_hash error: #{user.errors.inspect}")
          return nil
        end
      end
    end
  end
end
