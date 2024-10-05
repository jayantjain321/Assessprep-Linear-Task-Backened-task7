class RenameTitleToTaskTitleInTasks < ActiveRecord::Migration[7.2]
  def change
    rename_column :tasks, :title, :task_title # Rename title column to task_title for clarity
  end
end
