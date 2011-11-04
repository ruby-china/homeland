# coding: utf-8  
class TopicMailer < BaseMailer  
  def got_reply(topic,reply)
    @topic = topic
    @reply = reply
    # 排除不用发邮件的人
    return false if @topic.user.blank? or @reply.user.blank? or (@reply.user_id == @topic.user_id)
    mail(:to => topic.user.email, :subject => "《#{topic.title}》有了新回帖")
  end
  
  class Preview < MailView
    # Pull data from existing fixtures
    def got_reply
      ::TopicMailer.got_reply(Topic.first, Topic.first.replies.last)
    end
  end
end
