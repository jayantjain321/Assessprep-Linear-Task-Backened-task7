class Comment < ApplicationRecord
  acts_as_paranoid # Allows for soft deletion of comments

  scope :ordered_by_creation, -> { order(created_at: :desc) }

  # Associations
  belongs_to :task  #Each comment belongs to a task many-to-one relation
  belongs_to :user  #Each comment belongs to a user many-to-ont relation

  # Validations
  validates :text, presence: true 
end
