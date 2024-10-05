class CreateComments < ActiveRecord::Migration[7.2]
  def change
    # Create comments table to hold user comments on tasks
    create_table :comments do |t|
      t.string :text # Text content of the comment
      t.string :image # Image associated with the comment, if any
      t.references :task, null: false, foreign_key: true # Foreign key reference to the task the comment belongs to

      t.timestamps
    end
  end
end
