# coding: utf-8  
class NotesController < ApplicationController
  before_filter :require_user, :except => [:show]
  before_filter :init_base_breadcrumb
  
  def init_base_breadcrumb
    drop_breadcrumb("记事本", notes_path)
  end

  def index
    @notes = current_user.notes.paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("记事本")
    drop_breadcrumb("列表")
  end

  def show
    @note =  Note.find(params[:id])
    if not @note.publish 
      if current_user.blank? or @note.user_id != current_user.id
        render_404 and return
      end
    end
    set_seo_meta("查看 &raquo; 记事本")
    drop_breadcrumb("查看")
  end


  def new
    @note = current_user.notes.build
    set_seo_meta("新建 &raquo; 记事本")
    drop_breadcrumb(t("common.create"))
  end


  def edit
    @note = currenr_user.notes.find(params[:id])
    set_seo_meta("修改 &raquo; 记事本")
    drop_breadcrumb("修改")
  end


  def create
    @note = current_user.notes.new(params[:note])  

    if @note.save
      redirect_to(@note, :notice => '创建成功。')
    else
      render :action => "new"
    end
  end


  def update
    @note = currenr_user.notes.find(params[:id])

    if @note.update_attributes(params[:note])
      redirect_to(@note, :notice => '修改成功。')
    else
      render :action => "edit"
    end
  end

  def destroy
    @note = currenr_user.notes.find(params[:id])
    @note.destroy

    redirect_to(notes_url)
  end
end
