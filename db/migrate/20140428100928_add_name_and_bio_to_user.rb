class AddNameAndBioToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, default: '', null: false
    add_column :users, :bio, :string, default: '', null: false
  end
end
