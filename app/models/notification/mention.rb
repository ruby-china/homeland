class Notification::Mention < Notification::Base
  belongs_to :reply
end
