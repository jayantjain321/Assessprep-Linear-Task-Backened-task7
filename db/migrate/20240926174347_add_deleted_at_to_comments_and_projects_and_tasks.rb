class AddDeletedAtToCommentsAndProjectsAndTasks < ActiveRecord::Migration[7.2]
  def change

    # Adds a deleted_at column for soft deletion in comments, projects, and tasks
    add_column :comments, :deleted_at, :datetime
    add_column :projects, :deleted_at, :datetime
    add_column :tasks, :deleted_at, :datetime
  end
end
