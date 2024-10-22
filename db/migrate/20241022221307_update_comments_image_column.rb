class UpdateCommentsImageColumn < ActiveRecord::Migration[7.2]
  def change
     # Remove the image column
     remove_column :comments, :image, :string

     # Add images column as JSON with a default value of an empty array
     add_column :comments, :images, :json, default: []
  end
end
