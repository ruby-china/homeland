# frozen_string_literal: true

class TipOffsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def new
    @tipOff = TipOff.new(reporter_id: current_user.id, reporter_email: current_user.email)
  end

  def index
    @tipOffs = TipOff.find_by_reporter_id(current_user.id)
  end

  def create
    @tipOff = TipOff.new(tip_off_params)
    @tipOff.reporter_id = current_user.id
    @tipOff.create_time = Time.now
    if @tipOff.save
      # 给管理员群发通知
      admin_users = User.admin_users
      default_note = { notify_type: "create_tip_off", target_type: TipOff,
                      target_id: @tipOff.id, actor_id: current_user.id
                     }
      Notification.bulk_insert(set_size: 100) do |worker|
        admin_users.each do |admin_user|
          note = default_note.merge(user_id: admin_user[:id])
          worker.add(note)
        end
      end

      redirect_to((@tipOff[:content_url]),  notice: "举报创建成功，后续管理员将会查看您的举报并进行处理。过程中可能会通过邮箱 " + @tipOff["reporter_email"] + " 与您联系，请留意。")
    else
      redirect_to((@tipOff[:content_url]),  alert: "举报创建失败，请检查表格中所有必填字段是否均已选上。")
    end
  end

  def show
  end

  private

    def tip_off_params
      params.require(:tip_off).permit(:reporter_email, :tip_off_type, :body, :content_url, :content_author_id)
    end
end
