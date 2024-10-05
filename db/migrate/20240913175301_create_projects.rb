class CreateProjects < ActiveRecord::Migration[7.2]
  def change

    # Create projects table to manage project details
    create_table :projects do |t|
      t.string :name   # Name of the project
      t.text :description #Detailed Description
      t.string :status # Current status of the project (e.g., active, completed)
      t.date :start_date  # Start date of the project
      t.date :end_date #End Date of the project

      t.timestamps
    end
  end
end
