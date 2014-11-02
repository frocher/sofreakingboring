class AddInternalIdsToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :iid, :integer
  end
end
