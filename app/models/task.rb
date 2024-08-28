class Task < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :assign_date, presence: true
  validates :due_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[Todo Done InProgress InDevReview] }
  validates :priority, presence: true, inclusion: { in: %w[Urgent High Low] }
  validates :assigned_user, presence: true
end
