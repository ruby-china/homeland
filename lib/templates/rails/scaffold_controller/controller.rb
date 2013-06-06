# coding: UTF-8
class <%= controller_class_name %>Controller < <%= controller_class_name.include?('::') == true ? "#{controller_class_name.split('::').first}::" : ''  %>ApplicationController

  def index
    @<%= plural_file_name %> = <%= file_name.camelize %>.desc('_id').paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @<%= file_name %> = <%= orm_class.build(file_name.camelize) %>

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>
  end

  def create
    @<%= file_name %> = <%= orm_class.build(file_name.camelize, "params[:#{file_name}].permit!") %>

    respond_to do |format|
      if @<%= file_name %>.save
        format.html { redirect_to(<%= index_helper %>_path, :notice => '<%= human_name %> 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>].permit!)
        format.html { redirect_to(<%= index_helper %>_path, :notice => '<%= human_name %> 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= index_helper %>_path,:notice => "删除成功。") }
      format.json
    end
  end
end
