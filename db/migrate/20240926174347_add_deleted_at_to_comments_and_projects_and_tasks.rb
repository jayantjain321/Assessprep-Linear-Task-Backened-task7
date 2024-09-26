class AddDeletedAtToCommentsAndProjectsAndTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :deleted_at, :datetime
    add_column :projects, :deleted_at, :datetime
    add_column :tasks, :deleted_at, :datetime
  end
end
