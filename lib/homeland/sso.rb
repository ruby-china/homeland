module Homeland
  class SSO < SingleSignOn
    def self.sso_url
      Setting.sso['url']
    end

    def self.sso_secret
      Setting.sso['secret']
    end

    def self.generate_sso(return_path = '/')
      sso = new
      sso.nonce = SecureRandom.hex
      sso.register_nonce(return_path)
      sso.return_sso_url = Setting.base_url + '/auth/sso/login'
      sso
    end

    def self.generate_url(return_path = '/')
      generate_sso(return_path).to_url
    end

    def register_nonce(return_path)
      if nonce
        $redis.setex(nonce_key, NONCE_EXPIRY_TIME, return_path)
      end
    end

    def nonce_valid?
      nonce && $redis.get(nonce_key).present?
    end

    def return_path
      $redis.get(nonce_key) || '/'
    end

    def expire_nonce!
      if nonce
        $redis.del nonce_key
      end
    end

    def nonce_key
      "SSO_NONCE_#{nonce}"
    end

    def find_or_create_user(request = nil)
      sso_record = UserSSO.find_by(uid: external_id)

      if sso_record && (user = sso_record.user)
        sso_record.last_payload = unsigned_payload
      else
        user = match_email_or_create_user
        sso_record = user.sso
      end

      # if the user isn't new or it's attached to the SSO record we might be overriding username or email
      user.email = email if user.email.blank?
      user.login = username if user.login.blank?
      user.name = name if user.name.blank?
      user.bio = bio if user.bio.blank?

      # change external attributes for sso record
      sso_record.username = username
      sso_record.email = email
      sso_record.name = name
      sso_record.avatar_url = avatar_url

      user.save!
      user.update_tracked_fields!(request)

      # Add as admin
      if admin == true
        unless Setting.has_admin?(email)
          Setting.admin_emails = Setting.admin_emails + "\n" + email
        end
      end

      sso_record.save!
      sso_record && sso_record.user
    end

    def match_email_or_create_user
      user = User.find_by_email(email)
      unless user
        user_params = {
          email: email,
          name: name,
          login: Homeland::Username.sanitize(username || name),
          password: Devise.friendly_token[0, 20]
        }

        user = User.create!(user_params)
      end

      sso_record = user.sso || user.create_sso(
        last_payload: unsigned_payload,
        uid: external_id,
        username: username,
        email: email,
        name: name,
        avatar_url: avatar_url
      )

      sso_record.last_payload = unsigned_payload
      sso_record.uid = external_id
      user
    end
  end
end
