xml.instruct! :xml, version: "1.0"
xml.rss(version: "2.0"){
  xml.channel{
    xml.title t("rss.recent_topics_title", name: Setting.app_name)
    xml.link root_url
    xml.description(t("rss.recent_topics_description", name: Setting.app_name ))
    xml.language('en-us')
      for topic in @topics
        xml.item do
          xml.title topic.title
          xml.description markdown(topic.body)
          xml.author topic.user.login
          xml.pubDate(topic.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.link topic_url topic
          xml.guid topic_url topic
        end
      end
  }
}
