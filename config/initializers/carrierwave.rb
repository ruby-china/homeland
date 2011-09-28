CarrierWave.configure do |config|
  config.grid_fs_database = Mongoid.database.name
  config.grid_fs_host = '127.0.0.1'
  config.storage = :grid_fs
  config.grid_fs_access_url = APP_CONFIG['upload_url']
end
