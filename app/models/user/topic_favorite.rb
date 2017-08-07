class User
  module TopicFavorite
    extend ActiveSupport::Concern

    included do
      action_store :favorite, :topic
    end

    def favorites_count
      favorite_topic_actions.count
    end
  end
end
