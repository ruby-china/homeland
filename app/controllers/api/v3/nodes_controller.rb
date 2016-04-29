module Api
  module V3
    class NodesController < Api::V3::ApplicationController
      ##
      # 获取 Nodes 列表
      #
      # GET /api/v3/nodes
      #
      def index
        @nodes = Node.includes(:section).all
        render json: @nodes, meta: { total: Node.count }
      end

      ##
      # 获取单个 Node 详情
      #
      # GET /api/v3/nodes/:id
      #
      def show
        @node = Node.find(params[:id])
        render json: @node
      end
    end
  end
end
