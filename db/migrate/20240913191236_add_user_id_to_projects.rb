class AddUserIdToProjects < ActiveRecord::Migration[7.2]
  def change
    # Adds a user_id column to the projects table to associate a project with a user
    add_column :projects, :user_id, :integer
    add_index :projects, :user_id # Indexing user_id for faster lookups
  end
end
