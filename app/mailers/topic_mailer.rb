# coding: utf-8  
class TopicMailer < BaseMailer  
  def new_reply(reply_id,to)
    reply = Reply.find_by_id(reply_id)
    return false if reply.topic.blank?
    @topic = reply.topic
    @reply = reply
    mail(:to => @topic.user.email, :subject => "《#{@topic.title}》有了新回帖")
  end
  
  def self.got_reply(reply)
    # Thread.new {
      @reply = reply
      @topic = Topic.find_by_id(@reply.topic_id)
      User.where(:_id.in => @topic.follower_ids).excludes(:_id => @reply.user_id).each do |u|
        # 跳过，如果用户不允许发邮件
        # next if u.mail_new_answer == false
        TopicMailer.new_reply(reply.id,u.email).deliver
      end
      TopicMailer.new_reply(reply.id,@topic.user.email).deliver
    # }
  end
  
  class Preview < MailView
    # Pull data from existing fixtures
    def new_reply
      reply = Topic.first.replies.last
      ::TopicMailer.new_reply(reply.id, reply.user.email)
    end
  end
end
