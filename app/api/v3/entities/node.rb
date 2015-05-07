module V3
  module Entities
    class Node < Grape::Entity
      expose :id, :name, :topics_count, :summary, :section_id, :sort
      expose(:section_name) {|model, opts| model.section.try(:name) }
    end

  end
end