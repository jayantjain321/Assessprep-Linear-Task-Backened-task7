class RenameAssignedUserInTasks < ActiveRecord::Migration[7.2]
  def change
    rename_column :tasks, :assignedUser, :assigned_user
  end
end
