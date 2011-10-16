class AssetsController < ApplicationController
  def show
    @asset = Asset.find(params[:id])
    send_file @asset.path
  end
  
  def create
    @asset = Asset.create(params[:file])
    render :json => {:url => asset_url(@asset)}
  end  
end
