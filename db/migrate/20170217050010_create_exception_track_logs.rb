# This migration comes from exception_track (originally 20170217023900)
class CreateExceptionTrackLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :exception_tracks do |t|
      t.string :title
      t.text :body

      t.timestamps
    end

    drop_table :exception_logs
  end
end
