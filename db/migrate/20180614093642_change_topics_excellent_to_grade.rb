class ChangeTopicsExcellentToGrade < ActiveRecord::Migration[5.2]
  def up
    rename_column :topics, :excellent, :grade

    # 61 is old nopoint node
    Topic.connection.execute("update topics set grade = -1 where node_id = 61")
  end

  def down
    rename_column :topics, :grade, :excellent
  end
end
