class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    # Create tasks table to hold task details
    create_table :tasks do |t|
      t.string :title # Title of the task
      t.text :description # Detailed description of the task
      t.date :assign_date  # Date the task is assigned
      t.date :due_date # Due date for the task completion
      t.string :status # Current status of the task (e.g., Todo, In Progress, Done)
      t.string :priority  # Priority level of the task (e.g., Urgent, High, Low)
      t.string :assigned_user  # User assigned to the task

      t.timestamps
    end
  end
end
