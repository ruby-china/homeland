class TeamUsersController < ApplicationController
  require_module_enabled! :team

  before_action :set_team
  before_action :set_team_user, only: [:edit, :update, :destroy]
  before_action :authorize_team_owner!, except: [:index, :accept, :reject, :show]
  load_and_authorize_resource only: [:accept, :reject, :show]

  def index
    @team_users = @team.team_users
    if cannot? :update, @team
      @team_users = @team_users.accepted
    end
    @team_users = @team_users.order('id asc').includes(:user).page(params[:page])
  end

  def new
    @team_user = @team.team_users.new
    @team_user.role = :member
  end

  def create
    @team_user = TeamUser.new(team_user_params)
    @team_user.team_id = @team.id
    @team_user.actor_id = current_user.id
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
    if @team_user.update(params.require(:team_user).permit(:role))
      redirect_to(user_team_users_path(@team), notice: '保存成功')
    else
      render action: 'edit'
    end
  end

  def destroy
    @team_user.destroy
    redirect_to(user_team_users_path(@team), notice: '移除成功')
  end

  def show
    if @team_user.accepted?
      redirect_to user_team_users_path(@team)
    end
  end

  def accept
    @team_user.accepted!
    redirect_to(user_team_users_path(@team), notice: '接受成功，已加入组织')
  end

  def reject
    @team_user.destroy
    redirect_to(user_team_users_path(@team), notice: '已拒绝成功')
  end

  private

  def authorize_team_owner!
    authorize! :update, @team
  end

  def set_team_user
    @team_user = @team.team_users.find(params[:id])
  end

  def set_team
    @team = Team.find_by_login!(params[:user_id])
  end

  def team_user_params
    params.require(:team_user).permit(:login, :user_id, :role)
  end
end
