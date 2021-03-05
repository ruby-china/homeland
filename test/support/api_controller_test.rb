# frozen_string_literal: true

class APIControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  attr_accessor :current_user, :access_token

  setup do
    @current_user = FactoryBot.create(:avatar_user)
    @access_token = FactoryBot.create(:access_token, resource_owner_id: current_user.id)
  end

  def json
    response.parsed_body
  end

  def login_user!
    default_parameters[:access_token] = access_token.token
  end

  def login_admin!
    @current_user.update!(state: :admin)
    login_user!
  end

  def default_headers
    @default_headers ||= {}
  end

  def default_parameters
    @default_parameters ||= {}
  end

  # 覆盖 get, post .. 方法，让他们自己带上登录信息
  %i[get post put delete head].each do |method|
    class_eval <<~EOV, __FILE__, __LINE__ + 1
      def #{method}(path, parameters = nil, headers = nil)
        # override empty params and headers with default
        parameters = combine_parameters(parameters, default_parameters)
        headers = combine_parameters(headers, default_headers)
        super(path, params: parameters, headers: headers)
      end
    EOV
  end

  private

  def combine_parameters(argument, default)
    # if both of them are hashes combine them
    if argument.is_a?(Hash) && default.is_a?(Hash)
      default.merge(argument)
    else
      # otherwise return not nil arg or eventually nil if both of them are nil
      argument || default
    end
  end
end

MiniTest::Spec.register_spec_type(/^Api::V3/, APIControllerTest)
