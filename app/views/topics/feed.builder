
xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title "#{Setting.app_name}社区"
    xml.link root_url
    xml.description("#{Setting.app_name}社区最新发贴.")
    xml.language('en-us')
      for topic in @topics
        xml.item do
          xml.title topic.title
          xml.description format_topic_body(topic.body)
          xml.author topic.user.login       
          xml.pubDate(topic.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.link topic_url topic
          xml.guid topic_url topic
        end
      end
  }
}
