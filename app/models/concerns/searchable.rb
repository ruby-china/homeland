# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    has_one :search_document, as: :searchable, dependent: :delete

    after_commit on: :create do
      self.reindex!
    end

    after_update do
      self.reindex! # if self&.indexed_changed?
    end
  end

  def indexed_changed?
    true
  end

  def reindex!
    SearchDocument.index(self)
  end
end
