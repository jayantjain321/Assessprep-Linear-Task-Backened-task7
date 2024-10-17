class ChangeAssignedUserToAssignedUserIdInTasks < ActiveRecord::Migration[7.2]
  def change

    # Removes the assigned_user column from the tasks table,
    # as it is no longer needed.
    remove_column :tasks, :assigned_user, :string 

    # Adds an assigned_user_id column to the tasks table 
    # to properly reference the user assigned to the task.
    add_column :tasks, :assigned_user_id, :bigint 
  end
end
