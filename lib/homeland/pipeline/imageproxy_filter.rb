# frozen_string_literal: true

module Homeland
  class Pipeline
    class ImageproxyFilter < HTML::Pipeline::Filter
      def call
        return doc if Setting.imageproxy_url.blank?

        doc.search("img").each do |node|
          src = node.attr("src")
          img_uri = parse_uri(src)
          next if img_uri.blank?

          next if Setting.imageproxy_ignore_hosts.include?(img_uri.host)
          node.attributes["src"].value = imageproxy_url(src)
        end

        doc
      end

      def imageproxy_url(src)
        proxy_url = Setting.imageproxy_url.delete_suffix("/")
        [proxy_url, src].join("/")
      end

      def parse_uri(src)
        URI.parse(src)
      rescue
        nil
      end
    end
  end
end
