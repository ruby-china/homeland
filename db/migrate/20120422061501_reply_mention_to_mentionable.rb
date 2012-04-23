class ReplyMentionToMentionable < Mongoid::Migration
  def self.up
    Notification::Mention.where(:reply_id.ne => nil).each do |mention|
      mention[:mentionable_id] = mention["reply_id"]
      mention[:mentionable_type] = 'Reply'
      mention.save
      mention.unset :reply_id
    end
  end

  def self.down
    Notification::Mention.where(:reply_id => nil).each do |mention|
      mention["reply_id"] = mention["mentionable_id"]
      mention.save
      mention.unset :mentionable_id
      mention.unset :mentionable_type
    end
  end
end
