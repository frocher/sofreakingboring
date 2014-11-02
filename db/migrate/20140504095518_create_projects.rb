class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string   :code, null: false, default: ""
      t.string   :name, null: false, default: ""
      t.text     :description
      t.timestamps
    end

    add_attachment :projects, :attachment
  end
end
