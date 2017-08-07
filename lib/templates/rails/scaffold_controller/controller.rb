class <%= controller_class_name %>Controller < <%= controller_class_name.include?('::') == true ? "#{controller_class_name.split('::').first}::" : ''  %>ApplicationController
  before_action :set_<%= file_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_file_name %> = <%= file_name.camelize %>.desc('_id')
    @<%= plural_file_name %> = @<%= plural_file_name %>.page(params[:page])
  end

  def show
  end

  def new
    @<%= file_name %> = <%= orm_class.build(file_name.camelize) %>
  end

  def edit
  end

  def create
    @<%= file_name %> = <%= orm_class.build(file_name.camelize, "params[:#{file_name}].permit!") %>

    if @<%= file_name %>.save
      redirect_to(<%= index_helper %>_path, notice: '<%= human_name %> 创建成功。')
    else
      render action: "new"
    end
  end

  def update
    if @<%= file_name %>.update(params[:<%= file_name %>].permit!)
      redirect_to(<%= index_helper %>_path, notice: '<%= human_name %> 更新成功。')
    else
      render action: "edit"
    end
  end

  def destroy
    @<%= file_name %>.destroy
    redirect_to(<%= index_helper %>_path, notice: "删除成功。")
  end

  private

  def set_<%= file_name %>
    @<%= file_name %> = <%= orm_class.find(file_name.camelize, "params[:id]") %>
  end
end
