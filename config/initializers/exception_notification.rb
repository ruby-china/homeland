require 'exception_notification/rails'
require 'exception_notification/sidekiq'
require 'exception_notifier/database_notifier'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(ActionView::TemplateError
                                  ActionController::InvalidAuthenticityToken
                                  ActionController::BadRequest
                                  ActionView::MissingTemplate
                                  ActionController::UrlGenerationError
                                  ActionController::UnknownFormat)
  config.add_notifier :database, {}
end
