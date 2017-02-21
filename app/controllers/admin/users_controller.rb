module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = User.all
      if params[:q].present?
        qstr = "%#{params[:q].downcase}%"
        @users = @users.where('lower(login) LIKE ? or lower(email) LIKE ?', qstr, qstr)
      end
      if params[:type].present?
        @users = @users.where(type: params[:type])
      end
      @users = @users.order(id: :desc).page(params[:page])
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
      @user = User.find_by_login!(params[:id])
      @user.email = params[:user][:email]
      @user.login = params[:user][:login]
      @user.state = params[:user][:state]
      @user.verified = params[:user][:verified]

      if @user.update(params[:user].permit!)
        redirect_to(edit_admin_user_path(@user.id), notice: 'User was successfully updated.')
      else
        render action: 'edit'
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.user_type == :user
        @user.soft_delete
      else
        @user.destroy
      end

      redirect_to(admin_users_url)
    end

    def clean
      @user = User.find_by_login!(params[:id])
      if params[:type] == 'replies'
        # 为了避免误操作删除大量，限制一次清理 10 条，这个数字对刷垃圾回复的够用了。
        ids = Reply.unscoped.where(user_id: @user.id).recent.limit(10).pluck(:id)
        replies = Reply.unscoped.where(id: ids)
        topics = Topic.where(id: replies.collect(&:topic_id))
        replies.delete_all
        topics.each(&:touch)

        count = Reply.unscoped.where(user_id: @user.id).count
        redirect_to edit_admin_user_path(@user.id), notice: "最近 10 条删除，成功 #{@user.login} 还有 #{count} 条回帖。"
      end
    end
  end
end
