class Comment < ApplicationRecord
  acts_as_paranoid
  belongs_to :task
  belongs_to :user
  validates :text, presence: true 
end
