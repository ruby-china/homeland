# https://github.com/rails/rails/pull/3789

module ActionDispatch
  module Encoder

    # Beware that it modifies the parameter
    def self.encode_to_internal(str)
      str.force_encoding(Encoding::UTF_8)
      if !str.valid_encoding?
        replace_invalid_characters(str)
      end
      str.encode!
    end

    def self.replace_invalid_characters(str)
      for i in (0...str.size)
        if !str[i].valid_encoding?
          str[i] = "?"
        end
      end
    end
  end
end

module ActionDispatch
  module Http
    module Parameters
      private

      def normalize_encode_params_with_encode(params)
        if params.is_a?(String)
          ActionDispatch::Encoder::encode_to_internal(params)
        else
          normalize_encode_params_without_encode(params)
        end
      end

      alias_method_chain :normalize_encode_params, :encode
    end
  end
end

module ActionDispatch
  module Http
    class UploadedFile

      private

      def encode_filename(filename)
        # Encode the filename in the utf8 encoding, unless it is nil
        if filename
          ActionDispatch::Encoder::encode_to_internal(filename)
        else
          filename
        end
      end
    end
  end
end
