class AddIndexAndForeignKeyToAssignedUserIdInTasks < ActiveRecord::Migration[7.2]
  def change
    # Adds an index to the assigned_user_id column for faster querying.
    add_index :tasks, :assigned_user_id

    # Adds a foreign key constraint on assigned_user_id referencing the users table.
    add_foreign_key :tasks, :users, column: :assigned_user_id
  end
end
