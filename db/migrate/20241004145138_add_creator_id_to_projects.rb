class AddCreatorIdToProjects < ActiveRecord::Migration[7.2]
  def change

    # Adds a project_creator_id column to the projects table
    # to associate a project with its creator.
    add_column :projects, :project_creator_id, :bigint
  end
end
