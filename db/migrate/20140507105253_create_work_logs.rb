class CreateWorkLogs < ActiveRecord::Migration
  def change
    create_table :work_logs do |t|
      t.string  :description
      t.string  :day
      t.integer :worked
      t.integer :task_id
      t.timestamps
    end

    add_index(:work_logs, :task_id)
  end
end