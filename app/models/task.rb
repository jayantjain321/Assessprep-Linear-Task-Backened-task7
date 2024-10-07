class Task < ApplicationRecord
  
  acts_as_paranoid  # Allows for soft deletion of tasks

  #Associations
  belongs_to :user, foreign_key: 'assigned_user_id'  #Each task belongs to a user many-to-one Relation
  has_many :comments, dependent: :destroy #If a task deleted, commeent will be deleted too one-to-many relation
  belongs_to :project #Many-to-One Relation 
  
  #Validations
  validates :task_title, presence: true, uniqueness: true, length: { maximum: 255 }  # Name task_title be present and unique
  validates :description, presence: true, length: { maximum: 1000 }  # Description must be present and at least 1000 characters
  validates :assign_date, presence: true #Ensure assignment date is present
  validates :due_date, presence: true, comparison: { greater_than: :assign_date } # Ensure due date is present
  validates :status, presence: true, inclusion: { in: %w[Todo Done InProgress InDevReview] } # Valid status values
  validates :priority, presence: true, inclusion: { in: %w[Urgent High Low] } # Valid priority values
end

