class User < ApplicationRecord
    has_secure_password  # Secure password handling

    #Associations
    has_and_belongs_to_many :projects  #Many-to-Many Relation A user can have many projects
    has_many :tasks, dependent: :destroy,  foreign_key: 'assigned_user_id', dependent: :destroy  #One-to-Many Relation A user can have many tasks
    has_many :comments, dependent: :destroy #One-to-Many Relation A user can have many comments 
    

    #Vallidations
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } # Ensure email is present, unique, and valid format
    validates :position, presence: true
end
