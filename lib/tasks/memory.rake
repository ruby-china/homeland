# frozen_string_literal: true

task memory: :environment do
  require "homeland"
  include ApplicationHelper
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TextHelper

  str = Homeland::Markdown.example("zh-CN")

  a = []

  puts "Starting to profile memory..."
  b = {}
  puts "Before =>"
  print_memory

  count = 500_000
  step = (count / 100).to_i
  count.times do |i|
    sanitize_markdown(Homeland::Markdown.call(str))

    if i % step == 0
      print_memory
    end
  end

  print_memory
  puts GC.start
  puts "After GC"
  print_memory
end

def print_memory
  rss = (`ps -eo pid,rss | grep #{Process.pid} | awk '{print $2}'`.to_i / 1024.0).round(1)
  puts "rss: #{rss}mb live objects #{GC.stat[:heap_live_slots]}"
end
