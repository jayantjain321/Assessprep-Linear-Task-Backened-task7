class Project < ApplicationRecord
  acts_as_paranoid # Allows for soft deletion of projects

  # Associations
  has_and_belongs_to_many :users #Project Can have many users many-to-many relation
  has_many :tasks, dependent: :destroy # Deletes associated tasks if the project is deleted one-to-many relation

  # Validations
  validates :name, presence: true, uniqueness: true # Name must be present and unique
  validates :description, presence: true, length: { minimum: 10 }  # Description must be present and at least 100 characters
  validates :status, presence: true, inclusion: { in: %w[active completed], message: "%{value} is not a valid status" }  # Valid status values
  validates :start_date, presence: true  #Start Date
  validates :end_date, presence: true, comparison: { greater_than: :start_date } #End Date should be greater than Start Date
end
