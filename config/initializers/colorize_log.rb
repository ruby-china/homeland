if Rails.env.development?
  module ActionView
    class LogSubscriber < ActiveSupport::LogSubscriber
      def render_template(event)
        info do
          message = "  Rendered #{from_rails_root(event.payload[:identifier])}"
          message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
          message << " (#{event.duration.round(1)}ms)".colorize(:green)
        end
      end
      alias :render_partial :render_template
      alias :render_collection :render_template
    end
  end


  module ActionController
    class LogSubscriber < ActiveSupport::LogSubscriber
      %w(write_fragment read_fragment exist_fragment?
       expire_fragment expire_page write_page).each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{method}(event)
            return unless logger.info?
            key_or_path = (event.payload[:key] || event.payload[:path])
            human_name  = #{method.to_s.humanize.inspect}
            duration = "(\#{event.duration.round(1)}ms)".colorize(:green)
            info("  \#{human_name} \#{key_or_path} \#{duration}")
          end
        METHOD
      end
    end
  end


  module ActiveSupport
    module Cache
      class DalliStore
        def log(operation, key, options=nil)
          return unless logger && logger.debug? && !silence?
          return if operation.to_s == "fetch_hit"
          optname = "CACHE:".colorize(:magenta)
          logger.debug("  #{optname} #{operation.to_s.colorize(:yellow)} #{key}#{options.blank? ? "" : " (#{options.inspect})"}")
        end
      end
    end
  end

end