class CreateProjectMembers < ActiveRecord::Migration
  def change
    create_table :project_members do |t|
      t.integer  :user_id, null: false
      t.integer  :project_id, null: false
      t.integer  :role, default: 0, null: false
      t.timestamps
    end

    add_index(:project_members, :user_id)
    add_index(:project_members, :project_id)
    add_index(:project_members, [:user_id, :project_id], unique: true)
  end
end
