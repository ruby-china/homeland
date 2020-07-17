# frozen_string_literal: true

task reindex: :environment do
  print "Reindexing topics"
  Topic.find_each do |t|
    t.reindex!
    print "."
  end
  puts "done"

  print "Reindexing users"
  User.find_each do |t|
    t.reindex!
    print "."
  end
  puts "done"
  if defined? Page
    print "Reindexing pages"
    Page.find_each do |t|
      t.reindex!
      print "."
    end
    puts "done"
  end
end
