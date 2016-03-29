namespace :notifications do
  desc 'Upgrade notifications to new_notifications'
  task upgrade: :environment do
    class OldNotification < ApplicationRecord
      self.table_name = "notifications"
      self.inheritance_column = '_type'

      belongs_to :topic
      belongs_to :follower, class_name: 'User'
      belongs_to :node
      belongs_to :reply
      belongs_to :mentionable, polymorphic: true
    end

    OldNotification.where("created_at > '2016-01-01 00:00:00'").order('id asc').find_in_batches do |notes|
      Notification.transaction do
        notes.each do |note|
          hash = {
            user_id: note.user_id,
            notify_type: note.type.split("::").last.underscore,
            created_at: note.created_at,
            updated_at: note.updated_at,
            read_at: (note.read == true ? note.updated_at : nil)
          }

          print "Transmit notificaton:#{note.id}"

          if hash[:notify_type] == 'topic'
            next if note.topic.blank?
            hash[:actor_id] = note.topic.user_id
            hash[:target] = note.topic
          elsif hash[:notify_type] == 'topic_reply'
            next if note.reply.blank?
            next if note.reply.topic.blank?
            hash[:actor_id] = note.reply.user_id
            hash[:target] = note.reply
            hash[:second_target] = note.reply.topic
          elsif hash[:notify_type] == 'mention'
            next if note.mentionable.blank?
            hash[:target] = note.mentionable
            hash[:actor_id] = note.mentionable.user_id
            if note.mentionable.class == "Reply"
              hash[:second_target] = note.mentionable.topic
            end
          elsif hash[:notify_type] == "follow"
            hash[:actor_id] = note.follower_id
          elsif hash[:notify_type] == "node_changed"
            hash[:target] = note.topic
            hash[:second_target] = note.node
          end

          new_note = Notification.create(hash)
          puts " [ok] #{new_note.id}"
        end
      end
    end
  end
end
