require_relative "../../app/models/setting"

ActionMailer::Base.default_url_options = {host: Setting.domain, protocol: Setting.protocol}
