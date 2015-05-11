module APIV3Support
  extend ActiveSupport::Concern

  included do
    let!(:current_user) { Factory :user }
    let!(:access_token) { Factory(:access_token, resource_owner_id: current_user.id) }
    let(:json) { JSON.parse(response.body) }
    
    def login_user!
      default_parameters[:access_token] = access_token.token
    end

    def default_headers
      @default_headers ||= {}
    end

    def default_parameters
      @default_parameters ||= { }
    end

    # 覆盖 get, post .. 方法，让他们自己带上登录信息
    [:get, :post, :put, :delete, :head].each do |method|
      class_eval <<-EOV
      def #{method}(path, parameters = nil, headers = nil)
        # override empty params and headers with default
        parameters = combine_parameters(parameters, default_parameters)
        headers = combine_parameters(headers, default_headers)
        super(path, parameters, headers)
      end
      EOV
    end


    private
      def combine_parameters argument, default
        # if both of them are hashes combine them
        if argument.is_a?(Hash) && default.is_a?(Hash)
          default.merge(argument)
        else
          # otherwise return not nil arg or eventually nil if both of them are nil
          argument || default
        end
      end
  end
end