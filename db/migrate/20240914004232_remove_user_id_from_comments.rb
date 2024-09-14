class RemoveUserIdFromComments < ActiveRecord::Migration[7.2]
  def change
    remove_reference :comments, :user, null: false, foreign_key: true
  end
end
