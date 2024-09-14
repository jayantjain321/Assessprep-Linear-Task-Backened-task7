class AddProjectIdToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :project_id, :integer
  end
end
