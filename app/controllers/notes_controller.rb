# coding: utf-8
class NotesController < ApplicationController

  load_and_authorize_resource

  before_filter :init_base_breadcrumb

  def init_base_breadcrumb
    drop_breadcrumb(t("menu.notes"), notes_path)
  end

  def index
    @notes = current_user.notes.paginate(:page => params[:page], :per_page => 20)
    set_seo_meta t("menu.notes")
    drop_breadcrumb("列表")
  end

  def show
    @note =  Note.find(params[:id])
    set_seo_meta("查看 &raquo; #{t("menu.notes")}")
    drop_breadcrumb("查看")
  end

  def new
    @note = current_user.notes.build
    set_seo_meta("新建 &raquo; #{t("menu.notes")}")
    drop_breadcrumb(t("common.create"))
  end

  def edit
    @note = current_user.notes.find(params[:id])
    set_seo_meta("修改 &raquo; #{t("menu.notes")}")
    drop_breadcrumb("修改")
  end

  def create
    @note = current_user.notes.new(params[:note])

    if @note.save
      redirect_to(@note, :notice => t("common.create_success"))
    else
      render :action => "new"
    end
  end

  def update
    @note = current_user.notes.find(params[:id])

    if @note.update_attributes(params[:note])
      redirect_to(@note, :notice => t("common.update_success"))
    else
      render :action => "edit"
    end
  end

  def preview
    render :text => MarkdownConverter.convert( params[:body] )
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    @note.destroy

    redirect_to(notes_url)
  end
end
