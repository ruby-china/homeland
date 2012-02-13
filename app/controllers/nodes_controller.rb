# coding: utf-8
class NodesController < ApplicationController

  def index
    @nodes = Node.all
    render :json => @nodes, :only => [:name], :methods => [:id]
  end
end
