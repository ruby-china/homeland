# frozen_string_literal: true

module Api
  module V3
    # @abstract
    # FIXME: change to ActionController::API after jbuilder fix for Rails 5.2
    class ApplicationController < ActionController::Base
      include ActionController::Caching
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::SanitizeHelper
      include ApplicationHelper
      include ::ApplicationController::CurrentInfo

      skip_before_action :verify_authenticity_token

      helper_method :can?, :current_user, :current_ability, :meta
      helper_method :owner?, :markdown, :raw

      # 参数值不在允许的范围内
      # HTTP Status 400
      #
      #     { error: 'ParameterInvalid', message: '原因' }
      class ParameterValueNotAllowed < ActionController::ParameterMissing
        attr_reader :values
        def initialize(param, values) # :nodoc:
          @param = param
          @values = values
          super("param: #{param} value only allowed in: #{values}")
        end
      end

      # 无权限返回信息
      # HTTP Status 403
      #
      #     { error: 'AccessDenied', message: '原因' }
      class AccessDenied < StandardError; end

      # 数据不存在
      # HTTP Status 404
      #
      #     { error: 'ResourceNotFound', message: '原因' }
      class PageNotFound < StandardError; end

      rescue_from(ActionController::ParameterMissing) do |err|
        render json: {error: "ParameterInvalid", message: err}, status: 400
      end
      rescue_from(ActiveRecord::RecordInvalid) do |err|
        render json: {error: "RecordInvalid", message: err}, status: 400
      end
      rescue_from(AccessDenied) do |err|
        render json: {error: "AccessDenied", message: err}, status: 403
      end
      rescue_from(ActiveRecord::RecordNotFound) do
        render json: {error: "ResourceNotFound"}, status: 404
      end

      def requires!(name, opts = {})
        opts[:require] = true
        optional!(name, opts)
      end

      def optional!(name, opts = {})
        if opts[:require] && !params.key?(name)
          raise ActionController::ParameterMissing.new(name)
        end

        if opts[:values] && params.key?(name)
          values = opts[:values].to_a
          if !values.include?(params[name]) && !values.include?(params[name].to_i)
            raise ParameterValueNotAllowed.new(name, opts[:values])
          end
        end

        params[name] ||= opts[:default]
      end

      def error!(data, status_code = 400)
        render json: data, status: status_code
      end

      def error_404!
        error!({"error" => "Page not found"}, 404)
      end

      def current_user
        @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def current_ability
        @current_ability ||= Ability.new(current_user)
      end

      def can?(*args)
        current_ability.can?(*args)
      end

      def meta
        @meta || {}
      end
    end
  end
end
