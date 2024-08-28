class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.date :assign_date
      t.date :due_date
      t.string :status
      t.string :priority
      t.string :assigned_user

      t.timestamps
    end
  end
end
