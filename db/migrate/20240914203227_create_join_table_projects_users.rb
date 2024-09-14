class CreateJoinTableProjectsUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :projects_users, id: false do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false

      t.index :project_id
      t.index :user_id
      t.index [:project_id, :user_id], unique: true
    end

    add_foreign_key :projects_users, :projects
    add_foreign_key :projects_users, :users
  end
end
