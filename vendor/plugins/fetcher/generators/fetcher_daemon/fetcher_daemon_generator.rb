class FetcherDaemonGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.template 'config.yml', "config/#{file_name}.yml"
      m.template 'daemon', "script/#{file_name}_fetcher", :chmod => 0755
      m.template 'daemon.rb', "/lib/daemon.rb"
    end
  end
end
