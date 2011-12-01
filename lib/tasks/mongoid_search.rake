namespace :mongoid_search do
  desc 'Goes through all documents with search enabled and indexes the keywords.'
  task :index => :environment do
    if Mongoid::Search.classes.blank?
      Log.log "No model to index keywords.\n"
    else
      Mongoid::Search.classes.each do |klass|
        Log.silent = ENV['SILENT']
        Log.log "\nIndexing documents for #{klass.name}:\n"
        klass.index_keywords!
      end
      Log.log "\n\nDone.\n"
    end
  end
end