module Homeland
  # Generate Upload Image thumbs for development environment.
  class ImageThumb
    require 'mini_magick'
    require 'fileutils'

    attr_reader :outpath
    attr_reader :filename
    attr_reader :version

    def initialize(filename, version, pragma: false)
      @filename = filename
      @version = version
      @outpath = Rails.root.join('tmp', 'cache', 'uploads-thumb', "#{filename}-#{version}")

      notfound = !File.exists?(outpath)
      generate! if pragma || notfound
    end

    private

    def generate!
      filepath = Rails.root.join('public', 'uploads', filename)
      dest_dir = File.dirname(outpath)
      FileUtils.mkdir_p dest_dir unless File.exists? dest_dir

      @image = MiniMagick::Image.open(filepath)
      if resize?
        resize_to_limit!
      else
        resize_to_fill!
      end
      @image.write outpath
    end

    def geometry
      case version
      when 'large' then '1920x1920>'
      when 'lg' then '192x192'
      when 'md' then '96x96'
      when 'sm' then '48x48'
      when 'xs' then '32x32'
      else
        '32x32'
      end
    end

    def resize_to_limit!
      @image.resize(geometry)
    end

    # copy from Carrierwave::MiniMagick#resize_to_fill
    # http://www.rubydoc.info/github/carrierwaveuploader/carrierwave/CarrierWave/MiniMagick#resize_to_fill-instance_method
    def resize_to_fill!
      width, height = geometry.split('x').collect { |v| v.to_i }
      cols, rows = @image.dimensions
      if width != cols || height != rows
        scale_x = width/cols.to_f
        scale_y = height/rows.to_f
        if scale_x >= scale_y
          cols = (scale_x * (cols + 0.5)).round
          rows = (scale_x * (rows + 0.5)).round
          @image.resize "#{cols}"
        else
          cols = (scale_y * (cols + 0.5)).round
          rows = (scale_y * (rows + 0.5)).round
          @image.resize "x#{rows}"
        end
      end
      @image.gravity 'Center'
      @image.background 'rgba(255,255,255,0.0)'
      @image.extent(geometry)
    end

    def resize?
      version == 'large'
    end
  end
end