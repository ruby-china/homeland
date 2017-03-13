class NotesController < ApplicationController
  require_module_enabled! :note

  before_action :authenticate_user!
  before_action :set_recent_notes, only: [:index, :show, :edit, :new, :create, :update]
  load_and_authorize_resource

  def index
    @notes = current_user.notes.recent_updated.page(params[:page])
  end

  def show
    @note = Note.find(params[:id])
    @note.hits.incr(1)
  end

  def new
    @note = current_user.notes.build
  end

  def edit
    @note = current_user.notes.find(params[:id])
  end

  def create
    @note = current_user.notes.new(note_params)
    @note.publish = note_params[:publish] == '1'
    if @note.save
      redirect_to(@note, notice: t('common.create_success'))
    else
      render action: 'new'
    end
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update(note_params)
      redirect_to(@note, notice: t('common.update_success'))
    else
      render action: 'edit'
    end
  end

  def preview
    out = Homeland::Markdown.call(params[:body])
    render plain: out
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    @note.destroy

    redirect_to(notes_url)
  end

  private

  def set_recent_notes
    @recent_notes = current_user.notes.recent.limit(10)
  end

  def note_params
    params.require(:note).permit(:title, :body, :publish)
  end
end
