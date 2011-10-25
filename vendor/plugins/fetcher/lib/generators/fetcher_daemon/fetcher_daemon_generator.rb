require 'rails/generators'

class FetcherDaemonGenerator < Rails::Generators::NamedBase
  source_root File.join(File.dirname(__FILE__), '../../../generators/fetcher_daemon', 'templates')
    
  def create_fetcher_daemon
    copy_file('daemon.rb', "lib/daemon.rb")
    template('config.yml', File.join('config', "#{file_name}.yml"))
    template('daemon', File.join('script', "#{file_name}_fetcher"))
    chmod(File.join("script", "#{file_name}_fetcher"), 0755)
  end
end
