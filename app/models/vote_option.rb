class VoteOption

  include Mongoid::Document

  field :oid, type: Integer
  field :description, type: String
  field :percent, type: Float, default: 0.0
  field :voters, type: Array, default: []
  field :voters_count, type: Integer, default: 0

  embedded_in :poll, inverse_of: :options

  validates_uniqueness_of :oid
  validates_length_of :description, minimum: 2, maximum: 140, allow_blank: false

end
