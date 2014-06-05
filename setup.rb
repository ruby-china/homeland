#!/usr/bin/env ruby
ROW_SIZE = 80

class String
  COLORS = {
    :red    => 31,
    :green  => 32,
    :yellow => 33,
    :blue   => 34
  }
  def colorize(color)
    "\033[#{COLORS[color]}m#{self}\033[0m"
  end
end

def puts_section(info, &block)
  puts info
  puts "-"*ROW_SIZE
  yield block
  puts "-"*ROW_SIZE
  puts ""
end

def puts_line(info, &block)
  print info
  rsize = ROW_SIZE - info.length
  success = yield block
  if success == false
    puts "[Failed]".rjust(rsize).colorize(:red)
  else
    puts "[Done]".rjust(rsize).colorize(:green)
  end
end

def puts_line_with_yn(info, &block)
  print info
  rsize = ROW_SIZE - info.length
  success = yield block
  if success == false
    puts "[No]".rjust(rsize).colorize(:red)
  else
    puts "[Yes]".rjust(rsize).colorize(:green)
  end
end

def replace_file(file_name, from, to)
  File.open(file_name, "r+") do |f|
    out = ""
    f.each do |line|
        out << line.gsub(from, to)
    end
    f.pos = 0
    f.print out
    f.truncate(f.pos)
  end
end

puts "Now Installing Ruby China..."
puts "="*ROW_SIZE
puts ""

puts_section "Checking Package Dependencies..." do
  pkg_exist = true
  [["bundle","Bundler"],["mongod","MongoDB 2.0+"],["redis-server","Redis 2.0+"],["memcached","Memcached 1.4+"],["convert","ImageMagick 6.5+"]].each do |item|
    puts_line_with_yn item[1] do
      if `which #{item[0]}` == ""
        pkg_exist = false
        false
      else
        true
      end
    end
  end

  exit(0) if pkg_exist == false
end

# Config files
puts_section "Configure" do
  %w(config mongoid redis thin secrets).each do |fname|
    `cp config/#{fname}.yml.default config/#{fname}.yml`
  end

  print "Your MongoDB host (default: 127.0.0.1:27017):"
  host = gets.strip
  host = "127.0.0.1:27017" if host == ""
  replace_file('config/mongoid.yml','SETUP_DEVELOPMENT_HOST',host)

  print "Your Redis host (default: 127.0.0.1:6379):"
  host = gets.strip
  host = "127.0.0.1:6379" if host == ""
  replace_file('config/redis.yml','SETUP_REDIS_HOST',host.split(":")[0])
  replace_file('config/redis.yml','SETUP_REDIS_PORT',host.split(":")[1])
end

puts_line "Install gems..." do
  `bundle install`
end

puts_line "Seed default data..." do
  `bundle exec rake db:seed`
end

puts ""
puts "Ruby China Successfully Installed."
