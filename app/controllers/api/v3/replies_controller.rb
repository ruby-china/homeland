# frozen_string_literal: true

module Api
  module V3
    class RepliesController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, only: %i[update destroy]
      before_action :set_reply, only: %i[show update destroy]

      # 获取回帖的详细内容（一般用于编辑回帖的时候）
      #
      # GET /api/v3/replies/:id
      # @return [ReplyDetailSerializer]
      def show
      end

      # 更新回帖
      #
      # POST /api/v3/replies/:id
      #
      # @param body [String] 回帖内容 [required]
      # @return [ReplyDetailSerializer] 更新过后的数据
      def update
        raise AccessDenied unless can?(:update, @reply)

        requires! :body

        @reply.body = params[:body]
        @reply.save!
        render "show"
      end

      # 删除回帖
      #
      # DELETE /api/v3/replies/:id
      def destroy
        raise AccessDenied unless can?(:destroy, @reply)

        @reply.destroy
        render json: { ok: 1 }
      end

      private

        def set_reply
          @reply = Reply.find(params[:id])
        end
    end
  end
end
