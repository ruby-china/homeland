# coding: utf-8
# 用于修正 Topic 加入 last_reply_user_login 和 node_name 字段后，历史数据需要处理的问题
class FixTopicReplyUserLoginAndNodeName < Mongoid::Migration
  def self.up
    Topic.all.each do |item|
      item.last_reply_user_login = item.last_reply_user.try(:login) || nil
      item.save
    end
  end
end
