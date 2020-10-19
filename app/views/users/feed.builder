# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss(version: "2.0") do
  xml.channel do
    xml.title @user.fullname
    xml.link user_url(@user)
    xml.description(@user.tagline)
    xml.language("en-us")
    @topics.each do |topic|
      xml.item do
        xml.title topic.title
        xml.description topic.body_html
        xml.author @user.login
        xml.pubDate(topic.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link topic_url topic
        xml.guid topic_url topic
      end
    end
  end
end
