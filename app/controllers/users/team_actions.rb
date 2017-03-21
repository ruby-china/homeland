module Users
  module TeamActions
    extend ActiveSupport::Concern

    included do
      before_action :set_team, only: [:show]
    end

    private

    def team_show
      @topics = @user.topics.fields_for_list.last_actived.includes(:user)
      @topics = @topics.page(params[:page])
      fresh_when([@topics])
    end

    def only_team!
      render_404 if @user_type != :team
    end

    def set_team
      @team = @user
    end
  end
end
