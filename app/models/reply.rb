class Reply < ActiveRecord::Base
  belongs_to :topic, :counter_cache => true
  belongs_to :user
end
