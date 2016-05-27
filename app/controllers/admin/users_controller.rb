module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = User.all
      if params[:q]
        qstr = "%#{params[:q]}%"
        @users = @users.where('login LIKE ? or email LIKE ?', qstr, qstr)
      end
      @users = @users.order(id: :desc).paginate page: params[:page], per_page: 30
    end

    def show
      @user = User.find(params[:id])
    end

    def new
      @user = User.new
      @user._id = nil
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @user = User.new(params[:user].permit!)
      @user.email = params[:user][:email]
      @user.login = params[:user][:login]
      @user.state = params[:user][:state]
      @user.verified = params[:user][:verified]

      if @user.save
        redirect_to(admin_users_path, notice: 'User was successfully created.')
      else
        render action: 'new'
      end
    end

    def update
      @user = User.find_login!(params[:id])
      @user.email = params[:user][:email]
      @user.login = params[:user][:login]
      @user.state = params[:user][:state]
      @user.verified = params[:user][:verified]

      if @user.update_attributes(params[:user].permit!)
        redirect_to(edit_admin_user_path(@user.id), notice: 'User was successfully updated.')
      else
        render action: 'edit'
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.soft_delete

      redirect_to(admin_users_url)
    end

    def clean
      @user = User.find_login!(params[:id])
      if params[:type] == 'replies'
        # 为了避免误操作删除大量，限制一次清理 10 条，这个数字对刷垃圾回复的够用了。
        ids = @user.replies.recent.limit(10).pluck(:id)
        Reply.where(id: ids).delete_all
        redirect_to edit_admin_user_path(@user.id), notice: "最近 10 条删除，成功 #{@user.login} 还有 #{@user.replies.count} 条回帖。"
      end
    end
  end
end
