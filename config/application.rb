require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyChina
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    # Ensure App config files exist.
    if Rails.env.development?
      %w(config redis secrets elasticsearch).each do |fname|
        filename = "config/#{fname}.yml"
        next if File.exist?(Rails.root.join(filename))
        FileUtils.cp(Rails.root.join("#{filename}.default"), Rails.root.join(filename))
      end
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'zh-CN'
    config.i18n.available_locales = ['zh-CN', 'en', 'zh-TW']

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.i18n.fallbacks = true

    config.autoload_paths += [
      Rails.root.join('lib')
    ]
    config.eager_load_paths += [
      Rails.root.join('lib/ruby_china'),
      Rails.root.join('lib/exception_notifier')
    ]

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.to_prepare do
      Devise::Mailer.layout 'mailer'
      # Only Applications list
      Doorkeeper::ApplicationsController.layout 'simple'
      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout 'simple'
      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout 'simple'
    end

    config.action_cable.log_tags = [
      :action_cable, -> (request) { request.uuid }
    ]

    memcached_config = YAML.load_file("#{Rails.root}/config/memcached.yml")[Rails.env]
    config.cache_store = [:mem_cache_store, memcached_config['host'],
      { namespace: memcached_config['namespace'], compress: memcached_config['compress:'] }]

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use Rack::Attack

    config.action_cable.mount_path = '/cable'
  end
end

$memory_store = ActiveSupport::Cache::MemoryStore.new
$file_store = ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp/cache'))

I18n.config.enforce_available_locales = false

ActiveModelSerializers.config.adapter = :json
