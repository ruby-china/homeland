class TeamsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.owner_id = current_user.id
    if @team.save
      redirect_to(teams_path, notice: '创建成功')
    else
      render action: 'new'
    end
  end

  private

  def team_params
    params.require(:team).permit(:login, :name, :email, :bio)
  end
end
