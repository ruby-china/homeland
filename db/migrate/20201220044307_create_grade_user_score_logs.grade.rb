# This migration comes from grade (originally 20201201131239)
class CreateGradeUserScoreLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :grade_user_score_logs do |t|
      t.integer :user_id, comment: "user_id"
      t.string :message, comment: "积分变化消息"
      t.integer :score, comment: "变动积分"
      t.integer :after_score, comment: "变化后积分"
      t.integer :change_type, comment: "增加或者减少"

      t.timestamps
    end
  end
end
