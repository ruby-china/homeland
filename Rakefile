#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)
require "elasticsearch/rails/tasks/import"

Rails.application.load_tasks

task default: "bundle:audit"

require "sdoc"
require "rdoc/task"

rdoc_files = %w[
  README.md
  PLUGIN_DEV.md
  CONTRIBUTE.md
  API.md
  app/models
  app/controllers
  app/helpers
  lib/homeland.rb
  lib/single_sign_on.rb
  lib/homeland
]

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "public/doc"
  rdoc.generator = "sdoc"
  rdoc.template = "rails"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include(*rdoc_files)
end
