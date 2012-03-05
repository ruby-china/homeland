# coding: utf-8
class ProcessOldBodyFieldToMarkdown < Mongoid::Migration
  def self.up
    Topic.where(:body_html => nil).all.each do |t|
      t.body_html = MarkdownTopicConverter.format(t.body)
      t.save(:validate => false)
      print "."
      t = nil
    end
    Reply.where(:body_html => nil).all.each do |t|
      t.body_html = MarkdownTopicConverter.format(t.body)
      t.save(:validate => false)
      print "."
      t = nil
    end
    Comment.where(:body_html => nil).all.each do |t|
      t.body_html = MarkdownTopicConverter.format(t.body)
      t.save(:validate => false)
      print "."
      t = nil
    end
  end

  def self.down
  end
end