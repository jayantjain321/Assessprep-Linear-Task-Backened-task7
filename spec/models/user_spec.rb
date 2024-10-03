# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }  # FactoryBot creates a user with default attributes

  # Validation tests
  describe "Validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "is not valid without a name" do
      user.name = nil
      expect(user).to_not be_valid
    end

    it "is not valid without an email" do
      user.email = nil
      expect(user).to_not be_valid
    end

    it "is not valid with a duplicate email" do
      # Creating a user with the same email address
      create(:user, email: "duplicate@example.com")  # Create a user with a specific email
      
      # Build a new user with the same email
      user_with_duplicate_email = build(:user, email: "duplicate@example.com") 
      
      # Ensure this user with the duplicate email is invalid
      expect(user_with_duplicate_email).to_not be_valid
    end

    it "is not valid without a valid email format" do
      user.email = "invalidemail.com"
      expect(user).to_not be_valid
    end

    it "is not valid without a position" do
      user.position = nil
      expect(user).to_not be_valid
    end
  end

  # Association tests
  describe "Associations" do
    it { should have_and_belong_to_many(:projects) }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
  end
end
