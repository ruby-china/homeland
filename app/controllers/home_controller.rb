class HomeController < ApplicationController
  def uploads
    return render_404 if Rails.env.production?

    # This is a temporary solution for help generate image thumb
    # that when you use :file upload_provider and you have no Nginx image_filter configurations.
    # DO NOT use this in production environment.
    format, version = params[:format].split("!")
    filename = [params[:path], format].join(".")
    pragma = request.headers["Pragma"] == "no-cache"
    thumb = Homeland::ImageThumb.new(filename, version, pragma: pragma)
    if thumb.exists?
      send_file thumb.outpath, type: "image/jpeg", disposition: "inline"
    else
      render plain: "File not found", status: 404
    end
  end

  def error_404
    render_404
  end

  def markdown
  end

  def status
    render plain: "OK #{Time.now.iso8601}"
  end

  def manifest
    render json: Setting.manifest.to_json
  end
end
