# ================== Migration MongoDB into PostgreSQL
module DisableCounterCache
  extend ActiveSupport::Concern

  included do
    class << self
      alias_method_chain :update_counters, :disable
    end
  end

  module ClassMethods
    def update_counters_with_disable(id, counters)
      return true
    end
  end
end

def unset_callbacks(klass)
  klass.reset_callbacks(:save)
  klass.reset_callbacks(:commit)
  klass.reset_callbacks(:create)
  klass.reset_callbacks(:update)
end

def append(klass, doc)
  doc[:id] = doc.delete(:_id)
  if doc[:_type]
    doc[:type] = doc.delete(:_type)
  end

  if klass == User
    doc[:name] ||= ''
  end

  if klass == Note
    doc[:title] ||= ''
  end

  if klass == PageVersion
    doc[:desc] ||= ''
  end

  if klass == Reply
    doc[:body] = doc[:body].gsub("\u0000", "") unless doc[:body].nil?
    doc[:body_html] = doc[:body_html].gsub("\u0000", "") unless doc[:body_html].nil?
  end

  item = klass.unscoped.find_or_initialize_by(id: doc[:id].to_i)
  item.attributes = doc.reject{ |k,v| !item.attributes.keys.member?(k.to_s) }

  if klass == User
    item[:avatar] = doc[:avatar]
  end

  if item.save(validate: false)
    return item
  else
    raise [item.inspect, item.errors.full_messages.join(' ')].join(' ')
  end
end

def update_table_seq(table_name)
  last_id = last_id_in_table(table_name) + 1
  sql = "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH #{last_id};"
  puts sql
  ActiveRecord::Base.connection.execute(sql)
end

def last_id_in_table(table_name)
  rows = ActiveRecord::Base.connection.exec_query("SELECT id FROM #{table_name} ORDER BY id DESC LIMIT 1;")
  return 0 if rows.count == 0
  return rows[0]['id'].to_i
end

namespace :db do
  desc "将 MongoDB 的数据迁移到 PostgreSQL"
  task migrate_to_pg: :environment do
    require 'mongo'
    ActiveRecord::Base.send(:include, DisableCounterCache)
    thread_pool = 50
    table_names = %w(comments locations nodes notes notifications
                     page_versions pages replies sections site_configs
                     site_nodes sites topics)
    db = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'ruby_china')

    puts "================ User ==============="
    unset_callbacks(User)
    unset_callbacks(Authorization)
    db[:users].find({ _id: { '$gte' => last_id_in_table('users') } }).each do |doc|
      doc[:email] ||= ''
      u = append(User, doc)
      puts "User: #{u.id}"
      (doc['authorizations'] || []).each do |auth|
        auth[:user_id] = u.id
        a = append(Authorization, auth)
        puts "  Authorization: #{a.id}"
      end
    end
    update_table_seq('users')
    update_table_seq('authorizations')

    puts "\n\n================ Photo =============="
    unset_callbacks(Photo)
    db[:photos].find({ _id: { '$gte' => last_id_in_table('photos') }}).each do |doc|
      next if doc[:image].blank?
      item = Photo.unscoped.find_or_initialize_by(id: doc[:_id])
      item[:user_id] = doc[:user_id]
      item[:image] = doc[:image]
      item[:id] = doc[:_id]
      item[:created_at] = doc[:created_at]
      item[:updated_at] = doc[:updated_at]
      if item.save(validate: false)
        puts "Photo: #{item.id}"
      else
        raise "Photo #{item.id} save failed: #{item.errors.full_messages}"
      end
    end
    update_table_seq('photos')

    puts "\n\n================ Doorkeeper::Application =============="
    db[:oauth_applications].find({}).each do |doc|
      item = append(Doorkeeper::Application, doc)
      puts "Doorkeeper::Application: #{item.id}"
    end
    update_table_seq('oauth_applications')

    puts "\n\n================ Doorkeeper::AccessToken =============="
    db[:oauth_access_tokens].find({}).each do |doc|
      item = append(Doorkeeper::AccessToken, doc)
      puts "Doorkeeper::AccessToken: #{item.id}"
    end
    update_table_seq('oauth_access_tokens')

    puts "\n\n================ Doorkeeper::AccessGrant =============="
    db[:oauth_access_grants].find({}).each do |doc|
      item = append(Doorkeeper::AccessGrant, doc)
      puts "Doorkeeper::AccessGrant: #{item.id}"
    end
    update_table_seq('oauth_access_grants')

    table_names.each do |table_name|
      puts "\n\n================ #{table_name} =============="
      klass = table_name.classify.constantize
      klass = Notification::Base if klass == Notification
      unset_callbacks(klass)
      docs = []
      count = db[table_name].count({ _id: { '$ne' => 0 }})
      pg_count = klass.unscoped.count
      puts "#{table_name.upcase} COUNT IN MONGODB: #{count}"
      db[table_name].find({ _id: { '$gte' => last_id_in_table(table_name) } }).each_with_index do |doc, idx|
        docs << doc

        pg_idx = pg_count + idx
        # puts "----------- #{idx}, #{pg_idx}, #{count}"

        if docs.count == thread_pool || (pg_idx + thread_pool) >= count
          klass.transaction do
            docs.each do |doc|
              s = append(klass, doc)
              puts "#{table_name}: #{s.id}"
            end
            docs = []
          end
        end
      end

      puts "#{table_name.upcase} COUNT IN MONGODB: #{count}"
      puts "#{table_name.upcase} COUNT IN POSTGRESQL: #{klass.unscoped.count}"
      update_table_seq(table_name)
      sleep 4
    end

    puts ""
    puts "-----------------------------------------------------"
    puts "All migrate successed, you need restart Memcached to cleanup old cache value."
  end
end
