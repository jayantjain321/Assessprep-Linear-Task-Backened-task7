class RemoveProjectIdFromComments < ActiveRecord::Migration[7.2]
  def change
    remove_column :comments, :project_id, :integer
  end
end
