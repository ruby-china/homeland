require 'sprite_factory'
namespace :assets do
  desc 'recreate sprite images and css'
  task :resprite => :environment do 
    SpriteFactory.library = :chunkypng
    SpriteFactory.csspath = "image-path('sprites/$IMAGE')"
    dirs = Dir.glob("#{Rails.root}/app/assets/images/sprites/*/")
    dirs.each do |path|
      dir_name = path.split("/").last
      SpriteFactory.run!("app/assets/images/sprites/#{dir_name}", 
                          :output_style => "app/assets/stylesheets/sprites/#{dir_name}.scss", 
                          :selector => ".#{dir_name}_")
    end
  end
end
