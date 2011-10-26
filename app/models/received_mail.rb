# coding: utf-8
require "nokogiri"
module ReceivedMail
  
  def user
    if user = User.find_or_create_guest(self.from.first.downcase)
      return user
    else
      raise "User.find_or_create_guest 未获取到用户，也没有创建 Guest."
    end
  end
  
  def parent
    if self.references.nil? and self.in_reply_to.nil?
      return nil
    end
    
    puts "==== self.in_reply_to #{self['in-reply-to']}"
    puts "==== self.references #{self.references.inspect}"
    
    if self.references.is_a?(Array)
      parent_messageid = self.references.first
    else
      parent_messageid = self.references
    end
    
    parent_messageid = parent_messageid.to_s.tr('<>', '')
    
    if topic = Topic.find_by_message_id(parent_messageid)
      return topic
    else
      if self.cleaned_subject =~ /^re\:|^回复\:|^回复：/i
        raise "not found replay Topic. #{self.cleaned_subject} #{parent_messageid} \n"
      else
        # if no parent is found and subject is no reply, treat as new topic
        return nil
      end
    end
  end
  
  def node
    return Node.first
  end
  
  def create_topic
    if self.sender != Setting.google_group_email
      puts "--- [#{self.cleaned_subject}] skiped sender: #{self.sender}"
      return false 
    end
    
    if self.parent
      self.parent.replies << self.to_reply
    else
      self.node.topics << self.to_topic
    end
  end
  
  def to_reply
    reply = Reply.new
    reply.body = self.cleaned_text
    reply.user = self.user
    reply.source = "mail"
    reply.message_id = self.message_id.tr('<>', '')
    reply
  end
  
  def to_topic
    topic = Topic.new
    topic.node_id = self.node.id
    topic.title = self.cleaned_subject
    topic.body = self.cleaned_text
    topic.user = self.user
    topic.source = 'mail'
    topic.message_id = self.message_id.tr('<>', '')
    topic
  end

  def cleaned_subject
    puts "** #{self.encoding}"
    s = self.safe_str_encoding(self.subject,self.encoding)
    # remove first [tag] from subject
    s.sub!(/\[.+?\] ?/, '')
    s.strip!
    if s.size == 0
      s = '(no subject)'
    end
    s
  end

  def remove_signature(s)
    s = s.dup
    s.gsub!(/\n--(\n.+){0,3}\s*\Z/, '')
    s.gsub!(/\n-- (\n.+){0,6}\s*\Z/, '')
    s.gsub!(/\n-----+(\n.+){0,6}\s*\Z/, '')
    s.gsub!(/\n______+(\n.+){0,6}\s*\Z/, '')
    s
  end

  def cleaned_text
    s = self.plaintext_body
    
    begin
      s = remove_signature(s)
    
      # remove TOFU
      s.gsub!(/(\n>.*)+\s*\Z/, '')
      if $1
        # remove "xy wrote:"
        s.gsub!(/\s*\n.*wrote.*:\s*\Z/, '')
      end

      # remove attached "original message"
      s.gsub!(/\s*\n-+Original Message-+.*$/m, '')
    
      # remove too long quoting
      s.gsub!(/^(>.*\n)+?((>+.*\n){10})\s*/, '\3')
    
      s.strip!
    rescue => e
      puts "*** #{e}"
    end
    s
  end
  
  def encoding
    self.content_type.to_s.split("=").last.to_s
  end
  
  def plaintext_body
    if self.multipart?
      self.parts.each do |p|
        if p.content_type =~ /text\/plain/
          encoding = p.content_type.to_s.split("=").last.to_s
          return self.safe_str_encoding(p.body,encoding)
        end
      end
      raise "mail body multipart, but not text/plain part"
    else
      raise "body is not text/plain" unless self.content_type = 'text/plain'
      return self.safe_str_encoding(self.body,self.encoding)
    end
  end
  
  def safe_str_encoding(html, coding)
    doc = Nokogiri::HTML(html.to_s, nil, "utf-8")
    return doc.css("body").text
  end
end
