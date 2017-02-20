module Api
  module V3
    class NodesController < Api::V3::ApplicationController
      # 获取 Nodes 列表
      #
      # GET /api/v3/nodes
      # @return [Array<NodeSerializer>]
      def index
        @nodes = Node.includes(:section).all
        @meta = { total: Node.count }
      end

      ##
      # 获取单个 Node 详情
      #
      # GET /api/v3/nodes/:id
      # @return [NodeSerializer]
      def show
        @node = Node.find(params[:id])
      end
    end
  end
end
