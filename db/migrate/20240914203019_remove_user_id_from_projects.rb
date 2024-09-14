class RemoveUserIdFromProjects < ActiveRecord::Migration[7.2]
  def change
    remove_column :projects, :user_id, :integer
  end
end
