class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.string :text
      t.string :image
      t.references :task, null: false, foreign_key: true

      t.timestamps
    end
  end
end
