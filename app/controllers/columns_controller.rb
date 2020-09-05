class ColumnsController < ApplicationController

  before_action :authenticate_user!, only: %i[new edit create update destroy follow unfollow block unblock]
  load_and_authorize_resource only: %i[new edit create update destroy],:find_by => :slug
  before_action :set_column, only: [:show, :edit, :update, :destroy, :follow, :unfollow,  :block, :unblock]
  before_action :set_columns_have, only: [:new, :edit, :update, :create, :follow, :unfollow,  :block, :unblock]

  def index
    @columns = Column.all
  end

  def new
    @column = Column.new(user_id: current_user.id)
  end

  def show
    @user = @column.user
    @articles = @column.articles.withoutDraft.last_actived.page(params[:page])
  end

  def create
    @column = Column.new(column_params)
    @column.user_id = current_user.id
    if @column.save
      redirect_to(column_path(@column),  notice: I18n.t("column.column_created_successfully"))
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @column.update(column_params)
      redirect_to(column_path(@column), notice: I18n.t("column.column_updated_successfully"))
    else
      render action: "edit"
    end
  end

  def destroy
    @column.destroy
    redirect_to(columns_url)
  end

  def follow
    current_user.follow_column(@column)
    @column.reload
    render json: { code: 0, data: { followers_count: @column.followers_count } }
  end

  def unfollow
    current_user.unfollow_column(@column)
    @column.reload
    render json: { code: 0, data: { followers_count: @column.followers_count } }
  end

  def block
    current_user.block_column(@column)
    render json: { code: 0 }
  end

  def unblock
    current_user.unblock_column(@column)
    render json: { code: 0 }
  end

  protected

  def column_params
    params.require(:column).permit(:name, :description, :cover, :slug)
  end

  def set_column
    @column = Column.find_by_slug(params[:id])
  end

  def set_columns_have
    @column_already_have = current_user.columns
  end
end