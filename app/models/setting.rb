class Setting < Settingslogic
  source "#{Rails.root}/config/config.yml"
  namespace Rails.env
  load! if Rails.env.development?

  class << self
    def protocol
      self.https == true ? 'https' : 'http'
    end
  end
end
