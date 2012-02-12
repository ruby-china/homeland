mongoid_config = YAML.load_file("#{Rails.root}/config/mongoid.yml")[Rails.env]
CarrierWave.configure do |config|
  config.grid_fs_database = mongoid_config['database']
  config.grid_fs_host = mongoid_config['host']
  config.grid_fs_port = mongoid_config['port']
  config.grid_fs_username = mongoid_config['username']
  config.grid_fs_password = mongoid_config['password']
  config.storage = :grid_fs
  config.grid_fs_access_url = Setting.upload_url
end
