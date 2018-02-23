# frozen_string_literal: true

class Reply
  module Voteable
    extend ActiveSupport::Concern

    UPVOTES = %w[+1 :+1: :thumbsup: :plus1: 👍 👍🏻 👍🏼 👍🏽 👍🏾 👍🏿]

    included do
      after_commit :check_vote_chars_for_like_topic, on: :create, unless: -> { system_event? }
    end

    def upvote?
      (body || "").strip.start_with?(*UPVOTES)
    end

    private
      def check_vote_chars_for_like_topic
        return unless upvote?
        user.like(topic)
      end
  end
end
