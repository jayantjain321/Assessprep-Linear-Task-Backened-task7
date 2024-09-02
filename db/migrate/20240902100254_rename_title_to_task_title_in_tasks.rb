class RenameTitleToTaskTitleInTasks < ActiveRecord::Migration[7.2]
  def change
    rename_column :tasks, :title, :task_title
    rename_column :tasks, :assigned_user, :assignedUser
  end
end
