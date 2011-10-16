# coding: utf-8  
class NodesController < ApplicationController
  # GET /nodes
  # GET /nodes.xml
  def index
    @nodes = Node.all
    render :json => @nodes, :only => [:name], :methods => [:id]
  end
end
