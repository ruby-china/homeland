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
        puts "-------- #{err}"
        error!({ error: err }, 400)
      end

      def requires!(name, opts = {})
        opts[:require] = true
        optional!(name, opts)
      end

      def optional!(name, opts = {})
        if params[name].blank? && opts[:require] == true
          raise ActionController::ParameterMissing.new(name)
        end

        if opts[:values] && params[name].present?
          values = opts[:values].to_a
          if !values.include?(params[name]) && !values.include?(params[name].to_i)
            raise ParameterValueNotAllowed.new(name, values)
          end
        end

        if params[name].blank? && opts[:default].present?
          params[name] = opts[:default]
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
