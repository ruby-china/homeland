class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :provider
  field :uid
  embedded_in :user, :inverse_of => :authorizations
    
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  def self.find_from_hash(hash)
    find_by_provider_and_uid(hash['provider'], hash['uid'])
  end

  def self.create_from_hash(hash, user = nil)
    user ||= User.create_from_hash(hash)
    Authorization.create(:user_id => user.id, :uid => hash['uid'], :provider => hash['provider'])
  end
end

