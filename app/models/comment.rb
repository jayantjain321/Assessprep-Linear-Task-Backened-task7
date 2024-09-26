class Comment < ApplicationRecord
  acts_as_paranoid
  belongs_to :task
  validates :text, presence: true 
end
