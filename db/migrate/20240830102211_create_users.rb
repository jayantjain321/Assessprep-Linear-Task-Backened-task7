class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    # Create users table to store user information
    create_table :users do |t|
      t.string :name  # User's full name
      t.string :email # User's email address
      t.string :password_digest  # Encrypted password for user authentication
      t.string :position  # User's job position or role

      t.timestamps
    end
  end
end
