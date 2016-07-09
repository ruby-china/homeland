class TeamUsersController < ApplicationController
  before_action :set_team
  before_action :set_team_user, only: [:edit, :update, :destroy]
  before_action :authorize_team_owner!, except: [:index]

  def index
    @team_users = @team.team_users.unscoped.order('id asc').includes(:user).paginate(page: params[:page], per_page: 20)
  end

  def new
    @team_user = @team.team_users.new
    @team_user.role = :member
  end

  def create
    @team_user = TeamUser.new(team_user_params)
    @team_user.team_id = @team.id
    @team_user.status = :pendding
    if @team_user.save(context: :invite)
      redirect_to(user_team_users_path(@team), notice: '邀请成功。')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def authorize_team_owner!
    authorize! :update, @team
  end

  def set_team_user
    @team_user = @team.team_users.find(params[:id])
  end

  def set_team
    @team = Team.find_login!(params[:user_id])
  end

  def team_user_params
    params.require(:team_user).permit(:login, :user_id, :role)
  end
end
