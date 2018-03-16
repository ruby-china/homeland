# frozen_string_literal: true

module Topics
  module ListActions
    extend ActiveSupport::Concern

    included do
    end

    # GET /topics/popular
    # GET /topics/no_reply
    %i[no_reply popular].each do |name|
      define_method(name) do
        @topics = topics_scope.send(name).last_actived.page(params[:page])

        render_index(name)
      end
    end

    # GET /topics/last_reply
    def last_reply
      @topics = topics_scope.last_reply.page(params[:page])
      render_index("last_reply")
    end

    # GET /topics/favorites
    def favorites
      @topics = topics_scope(current_user.favorite_topics).page(params[:page])
      render_index("favorites")
    end

    def last
      @topics = topics_scope.recent.page(params[:page])
      render_index("recent")
    end

    def excellent
      @topics = topics_scope.excellent.recent.page(params[:page])
      render_index("excellent")
    end

    private

      def render_index(name)
        @page_title = [t("topics.topic_list.#{name.to_s}"), t("menu.topics")].join(" · ")
        render action: "index"
      end

      def topics_scope(base_scope = Topic)
        scope = base_scope.fields_for_list.without_hide_nodes
        if current_user
          scope = scope.without_nodes(current_user.block_node_ids)
          scope = scope.without_users(current_user.block_user_ids)
        end

        # must include :user, because it's uses for _topic.html.erb fragment cache_key
        scope.includes(:user)
      end
  end
end
