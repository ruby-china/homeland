module V3
  module Entities
    class Notification < Grape::Entity
      expose :id, :created_at, :updated_at, :read
      expose(:mention, if: lambda {|model, opts| model.is_a? ::Notification::Mention }) do |model, opts|
        # mode.mentionable_type could be "Reply" or "Topic"
        klass = case model.mentionable_type 
        when "Reply"
          V3::Entities::Reply
        when "Topic"
          V3::Entities::Topic
        else
          return nil
        end
        klass.represent(model.mentionable)
      end
      expose(:reply, if: lambda {|model, opts| model.is_a? ::Notification::TopicReply }) do |model, opts|
        V3::Entities::Reply.represent model.reply
      end
    end
  end
end