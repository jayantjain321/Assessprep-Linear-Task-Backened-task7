class AddLogMessageToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :log_message, :string
  end
end
