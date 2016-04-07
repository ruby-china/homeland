module StatusPage
  class RubyGems < StatusPage::Services::Base
    def service_name
      "Gems Mirror"
    end

    def check!
      result = Faraday.get('https://gems.ruby-china1.org') do |req|
        req.options.timeout = 3
      end
      if result.status >= 400
        raise "HTTP Response status: #{result.status}"
      end
    end
  end
end
