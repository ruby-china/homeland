# coding: utf-8
set :application, "ruby-china"
set :repository,  "git://github.com/huacnlee/ruby-china.git"
set :branch, "master"
set :scm, :git
set :user, "ruby"
set :deploy_to, "/home/#{user}/www/#{application}"
set :runner, "ruby"

role :web, "58.215.172.218"                          # Your HTTP server, Apache/etc
role :app, "58.215.172.218"                          # This may be the same as your `Web` server
role :db,  "58.215.172.218", :primary => true # This is where Rails migrations will run

# thin.yml 路径
set :thin_path, "#{deploy_to}/current/config/thin.yml"

namespace :deploy do
  task :start, :roles => :app do
    run "thin start -C #{thin_path}"
  end

  task :stop, :roles => :app do
    run "thin stop -O -C #{thin_path}"
  end

  # 要求服务器thin版本必须大于等于1.2.5，以支持-O参数进行one by one重启
  desc "Restart Application"
  task :restart, :roles => :app do
    run "thin restart -O -w 300 -C #{thin_path}"
  end
end

task :init_shared_path, :roles => :web do
  run "mkdir -p #{deploy_to}/shared/log"
  run "mkdir -p #{deploy_to}/shared/pids"
end

task :link_shared_config_yaml, :roles => :web do
  run "ln -sf #{deploy_to}/shared/config/*.yml #{deploy_to}/current/config/"
end

task :install_gems, :roles => :web do
  run "cd #{deploy_to}/current/; bundle install"
end

task :restart_resque, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
end

# 编译 assets
task :compile_assets, :roles => :web do
  run "cd #{deploy_to}/current/; bundle exec rake assets:precompile"
end

after "deploy:symlink", :init_shared_path, :link_shared_config_yaml, :install_gems, :compile_assets

set :default_environment, { 
  'PATH' => "/home/ruby/.rvm/gems/ruby-1.9.3-p0/bin:/home/ruby/.rvm/gems/ruby-1.9.3-p0@global/bin:/home/ruby/.rvm/rubies/ruby-1.9.3-p0/bin:/home/ruby/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => 'ruby-1.9.3-p0',
  'GEM_HOME' => '/home/ruby/.rvm/gems/ruby-1.9.3-p0',
  'GEM_PATH' => '/home/ruby/.rvm/gems/ruby-1.9.3-p0:/home/ruby/.rvm/gems/ruby-1.9.3-p0@global'
}
