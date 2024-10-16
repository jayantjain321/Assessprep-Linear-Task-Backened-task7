class AddLogMessageToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :log_message, :string
  end
end
