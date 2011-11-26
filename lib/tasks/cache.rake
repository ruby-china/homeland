namespace :cache do
  desc 'Clear caches in memcached'
  task :clear => :environment do
    ActionController::Base.cache_store.clear
  end
end
