#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'

Bundler.setup :default, :development

require 'thor/runner'
ARGV.unshift 'setup'
$thor_runner = true
Thor::Runner.start
