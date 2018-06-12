# frozen_string_literal: true

require "twemoji/svg"

Twemoji.configure do |config|
  config.asset_root = "https://twemoji.b0.upaiyun.com/2"
  config.file_ext   = "svg"
  config.class_name = "twemoji"
end
