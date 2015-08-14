class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :provider
  field :uid, type: String
  embedded_in :user, inverse_of: :authorizations

  validates :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }
end
