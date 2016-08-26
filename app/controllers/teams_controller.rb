class TeamsController < ApplicationController
  load_resource find_by: :login, except: [:city]
  load_and_authorize_resource except: [:city]

  before_action :set_team, only: [:show, :edit, :update, :destroy]

  def index
    render_404
  end

  def show
    redirect_to user_path(params[:id])
  end

  def city
    @location = Location.location_find_by_name(params[:id])
    if @location.blank?
      render_404
      return
    end

    @teams = Team.where(location_id: @location.id).fields_for_list.includes(:users)
    @teams = @teams.order(replies_count: :desc).paginate(page: params[:page], per_page: 20)

    render_404 if @teams.count == 0
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.owner_id = current_user.id
    if @team.save
      redirect_to(edit_team_path(@team), notice: '创建成功')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @team.update_attributes(team_params)
      redirect_to(edit_team_path(@team), notice: t('common.update_success'))
    else
      render action: 'edit'
    end
  end

  private

  def team_params
    params.require(:team).permit(:login, :name, :email, :email_public, :bio, :website, :twitter, :github, :location, :avatar)
  end

  def set_team
    @team = Team.find_login!(params[:id])
  end
end
