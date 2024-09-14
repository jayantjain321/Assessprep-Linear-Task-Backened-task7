class User < ApplicationRecord
    has_secure_password

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :position, presence: true

    has_and_belongs_to_many :projects
    has_many :tasks, dependent: :destroy
end
