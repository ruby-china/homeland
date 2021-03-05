# frozen_string_literal: true

module Homeland
  class Plugin
    # name of plugin, use var name style.
    attr_accessor :name

    # Plugin version
    attr_accessor :version

    # Description of plugin
    attr_accessor :description

    # Display name of plugin
    attr_accessor :display_name

    # Project url
    attr_accessor :url

    # set true if plugin link wants list in top navbar
    attr_accessor :navbar_link

    # set true if plugin link wants list in user drodown menu
    attr_accessor :user_menu_link

    # set true if plugin link wants list in admin navbar
    attr_accessor :admin_navbar_link

    # path of plugin root, for example /blog
    attr_accessor :root_path

    # path of plugin admin page for example /admin/blog
    attr_accessor :admin_path

    attr_accessor :source_path

    def uninstallable?
      source_path.starts_with? Rails.root.join("plugins").to_s
    end

    def <=>(other)
      self_idx = Setting.sorted_plugins.index(name)
      self_idx = 99999999 if self_idx.nil?
      other_idx = Setting.sorted_plugins.index(other.name)
      other_idx = 99999999 if other_idx.nil?

      self_idx <=> other_idx
    end

    def destroy
      return false unless uninstallable?
      FileUtils.rm_rf(source_path)
      true
    end

    class << self
      # Booting Homeland plugins
      def boot
        Dir.glob(Rails.root.join("plugins", "*")).each do |path|
          boot_file = File.join(path, "boot.rb")
          if File.exist?(boot_file)
            require boot_file
          end
        end

        # Must run on after Rails initialize
        # Because of the plugins wants to override the autoload classes.
        # ActiveSupport.on_load(:after_initialize) do
        ActiveSupport.on_load(:after_initialize) do
          Homeland.plugins.each do |plugin|
            require plugin.name
          rescue LoadError
          end
        end
      end

      # Install a new plugin via zip rack_file
      # Homeland::Plugin.install(params[:file])
      def install(zip_file)
        tmp = zip_file.tempfile
        FileUtils.move tmp.path, Rails.root.join("plugins")
        basename = File.basename(tmp.path)
        zip_filename = Rails.root.join("plugins", basename)
        `cd plugins; unzip -o #{zip_filename}`
        true
      ensure
        FileUtils.rm_f(zip_filename) if zip_filename
      end
    end
  end
end
