class AddUserIdToComments < ActiveRecord::Migration[7.2]
  def change
    # Adds a user reference to the comments table to associate comments with users
    add_reference :comments, :user, null: true, foreign_key: true
  end
end
