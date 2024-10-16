class AddLogMessageToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :log_message, :string
  end
end
