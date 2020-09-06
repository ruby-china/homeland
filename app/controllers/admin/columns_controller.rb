# frozen_string_literal: true

module Admin
  class ColumnsController < Admin::ApplicationController
    before_action :set_column, only: [:ban, :unban, :block]
    def index
      @columns = Column.all.banned
    end

    def ban
      authorize! :ban, @column
    end

    def block
      params[:reason_text] ||= params[:reason] || ""
      @column.update_attribute(:unseal_time, Time.now + 2.day)
      Notification.create notify_type: "admin_sms",
                          user_id: @column.user_id,
                          target: @column,
                          message: params[:reason_text]
      redirect_to(admin_columns_path, notice: "Column was successfully banned.")
    end

    def unban
      @column.update_attribute(:unseal_time, nil)
      redirect_to(admin_columns_path, notice: "Column was successfully banned.")
    end

    private

      def set_column
        @column = Column.unscoped.find(params[:id])
      end
  end
end
