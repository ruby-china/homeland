module Mongoid
  module Mentionable
    extend ActiveSupport::Concern
    included do
      field :mentioned_user_ids, :type => Array, :default => []
      before_save :extract_mentioned_users
      after_create :send_mention_notification
      after_destroy :delete_notifiaction_mentions
      has_many :notification_mentions, :as => :mentionable, :class_name => 'Notification::Mention'
    end

    # Wait for https://github.com/mongoid/mongoid/commit/2f94b5fab018b22a9e84ac2e988d4a3cf97e7f2e
    def delete_notifiaction_mentions
      Notification::Mention.where(:mentionable_id => self.id, :mentionable_type => self.class.name).delete_all
    end

    def mentioned_users
      User.where(:_id.in => mentioned_user_ids)
    end

    def mentioned_user_logins
      # 用于作为缓存 key
      ids_md5 = Digest::MD5.hexdigest(self.mentioned_user_ids.to_s)
      Rails.cache.fetch("#{self.class.name.downcase}:#{self.id}:mentioned_user_logins:#{ids_md5}") do
        User.where(:_id.in => self.mentioned_user_ids).only(:login).map(&:login)
      end
    end

    def extract_mentioned_users
      logins = body.scan(/@(\w{3,20})/).flatten
      if logins.any?
        self.mentioned_user_ids = User.where(:login => /^(#{logins.join('|')})$/i, :_id.ne => user.id).limit(5).only(:_id).map(&:_id).to_a
      end
    end

    def no_mention_users
      [user]
    end

    def send_mention_notification
      (mentioned_users - no_mention_users).each do |user|
        Notification::Mention.create :user => user, :mentionable => self
      end
    end
  end
end
