class Notification::Mention < Notification::Base
  belongs_to :reply

  # TODO waiting for https://github.com/huacnlee/mongoid_auto_increment_id/issues/3
  field :_type, :default => self.name
end
