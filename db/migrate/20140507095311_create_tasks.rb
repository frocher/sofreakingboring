class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string   :name, null: false, default: ""
      t.text     :description
      t.integer  :original_estimate
      t.integer  :remaining_estimate
      t.integer  :project_id, null: false
      t.integer  :assignee_id
      t.timestamps
    end

    add_index(:tasks, :assignee_id)
    add_index(:tasks, :project_id)
  end
end
