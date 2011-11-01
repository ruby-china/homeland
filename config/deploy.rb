# coding: utf-8
set :application, "ruby-china"
set :repository,  "git://github.com/huacnlee/ruby-china.git"
set :branch, "master"
set :scm, :git
set :user, "ruby"
set :deploy_to, "/home/#{user}/www/#{application}"
set :runner, "#{user}"

role :web, "ruby-china.org"                          # Your HTTP server, Apache/etc
role :app, "ruby-china.org"                          # This may be the same as your `Web` server
role :db,  "ruby-china.org", :primary => true # This is where Rails migrations will run

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
    run "thin restart -O -C #{thin_path}"
  end
end

task :init_shared_path, :roles => :web do
  run "mkdir -p #{deploy_to}/shared/log"
  run "mkdir -p #{deploy_to}/shared/pids"
end

task :install_gems, :roles => :web do
  run "cd #{deploy_to}/current/; bundle install"
end

# 编译 assets
task :compile_assets, :roles => :web do
  run "cd #{deploy_to}/current/; rm -Rf public/assets/; bundle exec rake assets:precompile"
end

after "deploy:symlink",:init_shared_path, :install_gems, :compile_assets