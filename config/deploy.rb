require 'bundler/capistrano'
require 'capistrano/sidekiq'
require 'rvm/capistrano'
require 'puma'
require 'puma/capistrano'

default_run_options[:pty] = true

set :rvm_ruby_string, 'ruby-2.3.0'
set :rvm_type, :user
set :application, 'ruby-china'
set :repository,  'git://github.com/ruby-china/ruby-china.git'
set :branch, 'master'
set :scm, :git
set :user, 'ruby'
set :deploy_to, "/data/www/#{application}"
set :runner, 'ruby'
# set :deploy_via, :remote_cache
set :git_shallow_clone, 1

set :puma_role, :app
set :puma_config_file, "config/puma.rb"

role :web, 'ruby-china.org'
role :app, 'ruby-china.org'
role :db,  'ruby-china.org', primary: true
role :queue, 'ruby-china.org'

task :link_shared, roles: :web do
  run "mkdir -p #{shared_path}/log"
  run "mkdir -p #{shared_path}/pids"
  run "mkdir -p #{shared_path}/assets"
  run "mkdir -p #{shared_path}/system"
  run "mkdir -p #{shared_path}/cache"
  run "ln -sf #{shared_path}/system #{current_path}/public/system"
  run "ln -sf #{shared_path}/assets #{current_path}/public/assets"
  run "ln -sf #{shared_path}/config/*.yml #{current_path}/config/"
  run "ln -sf #{shared_path}/config/initializers/secret_token.rb #{current_path}/config/initializers"
  run "ln -sf #{shared_path}/pids #{current_path}/tmp/"
  run "ln -sf #{shared_path}/cache #{current_path}/tmp/"
end

task :compile_assets, roles: :web do
  run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:precompile"
  run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:cdn"
end

task :migrate_db, roles: :web do
  run "cd #{current_path}; RAILS_ENV=production bundle exec rake db:migrate"
end

namespace :cable do
  task :start do
    run "cd #{current_path}; RAILS_ENV=production ./bin/cable"
  end

  task :stop do
    run "cd #{current_path} && #{pumactl_cmd} -S #{current_path}/tmp/pids/puma-cable.state stop"
  end

  task :restart do
    run "cd #{current_path} && #{pumactl_cmd} -S #{current_path}/tmp/pids/puma-cable.state restart"
  end
end

after 'deploy:finalize_update', 'deploy:symlink', :link_shared#, :migrate_db, :compile_assets
after 'deploy:start', 'cable:start'
after 'deploy:restart', 'cable:restart'
after 'deploy:stop', 'cable:stop'

