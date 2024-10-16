class Comment < ApplicationRecord
  include Loggable

  acts_as_paranoid # Allows for soft deletion of comments

  # Associations
  belongs_to :task  #Each comment belongs to a task many-to-one relation
  belongs_to :user  #Each comment belongs to a user many-to-ont relation

  # Validations
  validates :text, presence: true 
end
