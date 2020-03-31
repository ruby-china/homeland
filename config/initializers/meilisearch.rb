# frozen_string_literal: true

require "meilisearch"

$meilisearch = MeiliSearch::Client.new(ENV["MEILI_SEARCH_HOST"] || "http://127.0.0.1:7700")
