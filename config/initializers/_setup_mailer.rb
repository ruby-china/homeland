# frozen_string_literal: true

ActionMailer::Base.send(:prepend, Homeland::SetupMailer)
