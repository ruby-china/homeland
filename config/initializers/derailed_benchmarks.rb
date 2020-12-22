# frozen_string_literal: true

if Rails.env.development?
  DerailedBenchmarks.auth.user = -> { User.first }
end
