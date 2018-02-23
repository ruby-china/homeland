# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title t("rss.recent_node_topics_title", name: Setting.app_name, node_name: @node.name)
    xml.link root_url
    xml.description t("rss.recent_node_topics_description", name: Setting.app_name, node_name: @node.name)
    @topics.each do |topic|
      xml.item do
        xml.title topic.title
        xml.description markdown(topic.body)
        xml.author topic.user.login
        xml.pubDate topic.created_at.strftime("%a, %d %b %Y %H:%M:%S %z")
        xml.link topic_url(topic)
        xml.guid topic_url(topic)
      end
    end
  end
end
