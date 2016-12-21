module Homeland
  class Username
    def self.sanitize(username)
      username.gsub(/[^\w.-]/, '_')
    end
  end
end