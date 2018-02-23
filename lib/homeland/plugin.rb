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

    # add RSpec test path
    attr_accessor :spec_path
  end
end
