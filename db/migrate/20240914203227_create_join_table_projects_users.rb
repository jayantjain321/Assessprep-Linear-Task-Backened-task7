class CreateJoinTableProjectsUsers < ActiveRecord::Migration[7.2]
  def change

    # Creates a join table for many-to-many relationship between projects and users
    create_table :projects_users, id: false do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false

      t.index :project_id # Indexing project_id for faster lookups
      t.index :user_id # Indexing user_id for faster lookups
      t.index [:project_id, :user_id], unique: true # Ensuring uniqueness for the pair
    end

    add_foreign_key :projects_users, :projects # Adding foreign key constraint
    add_foreign_key :projects_users, :users # Adding foreign key constraint
  end
end
