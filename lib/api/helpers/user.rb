module RubyChina
  module APIHelper
    module User
      def current_user
        @current_user ||= ::User.where(:private_token => params[:token]).first
      end
    end
  end
end
