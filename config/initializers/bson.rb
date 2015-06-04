class BSON::ObjectId
  class << self
    def legal?(s)
      /\A\h{24}\z/ === s.to_s
    end
  end
end
