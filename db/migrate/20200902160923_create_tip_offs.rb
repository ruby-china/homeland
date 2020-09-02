class CreateTipOffs < ActiveRecord::Migration[6.0]
  def change
    create_table :tip_offs do |t|
      t.integer :reporter_id # 举报人用户id
      t.string :reporter_email # 举报人邮箱地址，用于回复
      t.string :tip_off_type # 举报类型（垃圾广告、违规内容、不友善内容、其它理由）
      t.string :body # 举报说明
      t.datetime :create_time # 举报时间
      t.string :content_url # 被举报内容 url
      t.string :content_author_id # 被举报内容作者id
      t.integer :follower_id # 跟进的管理员用户id
      t.datetime :follow_time # 跟进时间
      t.string :follow_result # 跟进结果
      t.datetime :deleted_at # 删除时间
    end

    add_index :tip_offs, :reporter_id
  end
end
