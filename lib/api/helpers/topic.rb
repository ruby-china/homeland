module RubyChina
  module APIHelper
    module Topic
      def max_page_size
        100
      end

      def default_page_size
        15
      end

      def page_size
        size = params[:size].to_i
        [size.zero? ? default_page_size : size, max_page_size].min
      end
    end
  end
end
