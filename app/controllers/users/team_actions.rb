module Users
  module TeamActions
    extend ActiveSupport::Concern

    included do
      before_action :set_team, only: [:show]
    end

    private

    def team_show
      @topics = Topic.where(user_id: @team.user_ids).fields_for_list.last_actived.includes(:user)
      @topics = @topics.page(params[:page])
    end

    def only_team!
      render_404 if @user_type != :team
    end

    def set_team
      @team = @user
    end
  end
end
