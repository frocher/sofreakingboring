class CreateProjectSnapshots < ActiveRecord::Migration
  def change
    create_table :project_snapshots do |t|
      t.integer  :project_id,   :null => false
      t.integer  :task_count
      t.integer  :original_estimate
      t.integer  :work_logged
      t.integer  :remaining_estimate
      t.timestamps
    end
    add_index :project_snapshots, :project_id
  end
end
