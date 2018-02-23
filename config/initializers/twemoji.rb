# frozen_string_literal: true

require "twemoji/svg"

Twemoji.configure do |config|
  config.asset_root = "https://cdn.bootcss.com/twemoji/2.5.0/2"
  config.file_ext   = "svg"
  config.class_name = "twemoji"
end
