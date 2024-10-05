class RemoveUserIdFromProjects < ActiveRecord::Migration[7.2]
  def change
    # Removes the user_id column from the projects table
    remove_column :projects, :user_id, :integer
  end
end
