module Api
  module V3
    class NodesController < ApplicationController
      def index
        @nodes = Node.includes(:section).all
        render json: @nodes, meta: { total: Node.count }
      end

      def show
        @node = Node.find(params[:id])
        render json: @node
      end
    end
  end
end
