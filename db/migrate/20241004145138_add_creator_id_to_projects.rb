class AddCreatorIdToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :project_creator_id, :integer
  end
end
