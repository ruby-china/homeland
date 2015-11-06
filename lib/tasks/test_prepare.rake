namespace :test do
  desc 'preparing config files...'
  task :prepare do
    %w(config mongoid redis).each do |cfgfile|
      system("cp config/#{cfgfile}.yml.default config/#{cfgfile}.yml") unless File.exist?("config/#{cfgfile}.yml")
    end
  end
end
