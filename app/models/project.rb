class Project < ApplicationRecord
  acts_as_paranoid
  has_and_belongs_to_many :users
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 10 }
  validates :status, presence: true, inclusion: { in: %w[active completed], message: "%{value} is not a valid status" }
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than: :start_date }
end
