# coding: utf-8  
class NotesController < ApplicationController
  before_filter :require_user, :except => [:show]

  def index
    @notes = current_user.notes.paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("记事本")
  end

  def show
    @note =  Note.find(params[:id])
    if not @note.publish 
      if current_user.blank? or @note.user_id != current_user.id
        render_404 and return
      end
    end
    set_seo_meta("查看 &raquo; 记事本")
  end


  def new
    @note = Note.new
    set_seo_meta("新建 &raquo; 记事本")
  end


  def edit
    @note = Note.find(params[:id])
    set_seo_meta("修改 &raquo; 记事本")
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
    @note = Note.find(params[:id])
    if @note.user_id != current_user.id
      render_404
    end

    if @note.update_attributes(params[:note])
      redirect_to(@note, :notice => '修改成功。')
    else
      render :action => "edit"
    end
  end

  def destroy
    @note = Note.find(params[:id])
    if @note.user_id != current_user.id
      render_404
    end
    @note.destroy

    redirect_to(notes_url)
  end
end
