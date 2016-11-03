class HomeController < ApplicationController
  def index
    @excellent_topics = Topic.excellent.recent.fields_for_list.limit(20).to_a
    fresh_when([@excellent_topics, Setting.index_html])
  end

  def uploads
    # This is a temporary solution for help generate image thumb
    # that when you use :file upload_provider and you have no Nginx image_filter configurations.
    # DO NOT use this in production environment.
    format, version = params[:format].split("!")
    filename = "#{params[:path]}.#{format}"
    thumb = Homeland::ImageThumb.new(filename, version)
    send_file thumb.outpath, type: 'image/jpeg', disposition: 'inline'
  end

  def api
    redirect_to "/api-doc/"
  end

  def error_404
    render_404
  end

  def markdown
  end
end
