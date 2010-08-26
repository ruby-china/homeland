# coding: utf-8  
class Node < ActiveRecord::Base
  validates_presence_of :name, :summary
  validates_uniqueness_of :name
  belongs_to :section
  has_many :topics

  scope :hots, :order => "topics_count desc"

   # 存放用户最近访问节点
  def self.set_user_last_visited(user_id,node_id)
    last_visites = get_user_last_visites(user_id)
    last_visites.delete(node_id)

    if(last_visites.length == 10)
      last_visites.pop
    end
    last_visites.insert(0,node_id)
    Rails.cache.write("Node:get_user_last_visites:#{user_id}",last_visites)
  end

  # 取得用户最近访问的节点
  def self.get_user_last_visites(user_id)
    last_visites = Rails.cache.read("Node:get_user_last_visites:#{user_id}")
    if last_visites.blank?
      last_visites = []
      Rails.cache.write("Node:get_user_last_visites:#{user_id}", last_visites)
    end
    return last_visites.dup
  end

  def self.find_last_visited_by_user(user_id,limit = 10)
    ids = get_user_last_visites(user_id)
    if ids.blank?
      return []
    else
      find(:all, :limit => limit, :conditions => "id in (#{ids.join(',')})")
    end
  end
end
