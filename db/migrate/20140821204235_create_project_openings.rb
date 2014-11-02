class CreateProjectOpenings < ActiveRecord::Migration
  def change
    create_table :project_openings do |t|
      t.integer  :project_id, :null => false
      t.integer  :user_id,    :null => false
      t.integer  :touched
      t.timestamps
    end
    add_index :project_openings, :project_id
    add_index :project_openings, :user_id
    add_index :project_openings, [:user_id, :project_id], unique: true
  end
end
