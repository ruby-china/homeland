# coding: utf-8  
class TopicMailer < BaseMailer  
  def got_reply(topic,reply)
    @topic = topic
    @reply = reply
    # 排除不用发邮件的人
    return false if @topic.user.blank? or @reply.user.blank? or (@reply.user_id == @topic.user_id)
    mail(:to => topic.user.email, :subject => "你发布的贴子[#{topic.title}]收到了回贴")
  end
end
