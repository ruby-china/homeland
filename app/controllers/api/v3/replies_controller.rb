module Api
  module V3
    class RepliesController < ApplicationController
      before_action :doorkeeper_authorize!, only: [:update, :destroy]
      before_action :set_reply, only: [:show, :update, :destroy]

      def show
        render json: @reply, serializer: ReplyDetailSerializer
      end

      def update
        raise AccessDenied unless can?(:update, @reply)

        requires! :body

        @reply.body = params[:body]
        @reply.save!
        render json: @reply, serializer: ReplyDetailSerializer, status: 201
      end

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
