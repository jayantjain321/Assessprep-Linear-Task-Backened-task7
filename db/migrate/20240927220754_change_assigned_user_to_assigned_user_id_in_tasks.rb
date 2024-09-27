class ChangeAssignedUserToAssignedUserIdInTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column :tasks, :assigned_user, :string
    add_column :tasks, :assigned_user_id, :integer
  end
end
