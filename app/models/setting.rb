# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join('config/config.yml')

  class << self
    def protocol
      self.https == true ? 'https' : 'http'
    end

    def host
      [self.protocol, self.domain].join("://")
    end
  end
end
