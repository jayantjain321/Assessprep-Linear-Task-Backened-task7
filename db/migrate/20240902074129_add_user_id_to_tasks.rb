class AddUserIdToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :user_id, :integer # Add user_id column to tasks table for associating tasks with users
    add_index :tasks, :user_id # Create an index on user_id for faster querying
  end
end
