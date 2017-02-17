require 'exception_notification/sidekiq'

ExceptionTrack.configure do
  # self.environments = %i(production)
end

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(
    ActionView::TemplateError
    ActionController::InvalidAuthenticityToken
    ActionController::BadRequest
    ActionView::MissingTemplate
    ActionController::UrlGenerationError
    ActionController::UnknownFormat
  )
end
