class PageVersion
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page
  field :version, :type => Integer
  field :desc
  field :body
  field :slug
  field :title

  index :page_id
  index [[:page_id, Mongo::ASCENDING], [:version,Mongo::ASCENDING]]
end
