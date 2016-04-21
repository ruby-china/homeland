module Api
  module V3
    class ApplicationController < ActionController::API
      class ParameterValueNotAllowed < ActionController::ParameterMissing
        attr_reader :values
        def initialize(param, values) # :nodoc:
          @param = param
          @values = values
          super("param: #{param} value only allowed in: #{values}")
        end
      end

      rescue_from(ActionController::ParameterMissing, ActiveRecord::RecordInvalid) do |err|
        error!({ error: err }, 400)
      end

      def requires!(name, opts = {})
        if params[name].blank?
          raise ActionController::ParameterMissing.new(name)
        end

        if opts[:values] && !opts[:values].include?(params[name])
          raise ParameterValueNotAllowed.new(name, opts[:values])
        end
      end

      def error!(data, status_code)
        render json: data, status: status_code
      end

      def error_404!
        error!({ 'error' => 'Page not found' }, 404)
      end

      def current_user
        @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
