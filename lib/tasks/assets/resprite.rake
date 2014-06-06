namespace :assets do
  desc 'recreate sprite images and css'
  task resprite: :environment do
    require 'sprite_factory'
    require 'chunky_png'
    SpriteFactory.library = :chunkypng
    SpriteFactory.csspath = "image-path('sprites/$IMAGE')"
    SpriteFactory.layout = "vertical"
    dirs = Dir.glob("#{Rails.root}/app/assets/images/sprites/*/")
    dirs.each do |path|
      dir_name = path.split("/").last
      is_2x = dir_name.include?("@2x")
      SpriteFactory.run!("app/assets/images/sprites/#{dir_name}",
                          output_style: "app/assets/stylesheets/sprites/#{dir_name}.scss",
                          selector: ".#{dir_name}_") do |images|
        result = []
        result << "@media only screen and (-webkit-device-pixel-ratio: 2){" if is_2x
        
        background_size = ""
        if is_2x
          image_width = images.first[1][:width]
          image_height = images.first[1][:height] * images.length
          background_size = "background-size:#{image_width/2}px #{image_height/2}px;"
        end
        
        images.each do |img|
          style = img[1][:style]
          if is_2x
            style.gsub!("width: #{img[1][:width]}px; height: #{img[1][:width]}px;",
                        "width: #{img[1][:width]/2}px; height: #{img[1][:width]/2}px;")
            style.gsub!("#{img[1][:x]}px #{0 - img[1][:y]}px no-repeat","#{img[1][:x] / 2}px #{0 - img[1][:y] / 2}px no-repeat")
          end
          result << ".#{dir_name.gsub("@2x","")}_#{img[0]} { display:inline-block; #{style}; #{background_size} }"
        end
        result << "}" if is_2x
        result.join("\n")
      end            
    end
  end
end
