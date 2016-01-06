require 'elasticsearch/model'
require 'elasticsearch/model/callbacks'

config = YAML.load_file("#{Rails.root}/config/elasticsearch.yml")[Rails.env]

Elasticsearch::Model.client = Elasticsearch::Client.new host: config['host']
