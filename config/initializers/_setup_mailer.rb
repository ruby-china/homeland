# frozen_string_literal: true

ActionMailer::Base.default_url_options = {host: Setting.domain, protocol: Setting.protocol}
