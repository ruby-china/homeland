module TopicReference
  extend ActiveSupport::Concern

  included do
    after_commit :extract_references, on: %i[create update]
  end

  def extract_references
    TopicReferenceJob.perform_later(self.class.name, id)
  end
end
