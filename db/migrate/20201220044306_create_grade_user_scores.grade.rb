# This migration comes from grade (originally 20201201131134)
class CreateGradeUserScores < ActiveRecord::Migration[6.0]
  def change
    create_table :grade_user_scores do |t|
      t.integer :score, default: 0, comment: "用户积分"
      t.integer :user_id, comment: "user_id"

      t.timestamps
    end
  end
end
