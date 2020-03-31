# frozen_string_literal: true

namespace :search do
  task reindex: :environment do
    print "Reindex search indexes..."
    Topic.find_each do |topic|
      topic.reindex
      print "."
    end
    puts "Done"
  end
end
