if Rails.env.development?
  DerailedBenchmarks.auth.user = -> { User.first }
end
