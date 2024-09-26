class Task < ApplicationRecord
  
  acts_as_paranoid

  belongs_to :user
  has_many :comments, dependent: :destroy
  belongs_to :project
  
  validates :task_title, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :assign_date, presence: true
  validates :due_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[Todo Done InProgress InDevReview] }
  validates :priority, presence: true, inclusion: { in: %w[Urgent High Low] }
  validates :assigned_user, presence: true
end

