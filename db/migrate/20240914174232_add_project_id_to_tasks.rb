class AddProjectIdToTasks < ActiveRecord::Migration[7.2]
  def change
    # Adds a project reference to the tasks table for associating tasks with projects
    add_reference :tasks, :project, foreign_key: true
  end
end
