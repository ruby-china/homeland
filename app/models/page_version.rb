class PageVersion
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :page
  field :version, type: Integer
  field :desc
  field :body
  field :slug
  field :title

  index page_id: 1
  index page_id: 1, version: 1
end
