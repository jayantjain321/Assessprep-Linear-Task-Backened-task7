class AddProjectIdToTasks < ActiveRecord::Migration[7.2]
  def change
    add_reference :tasks, :project, foreign_key: true
  end
end
