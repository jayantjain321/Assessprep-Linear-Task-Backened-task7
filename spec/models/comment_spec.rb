require 'rails_helper'

# spec/models/comment_spec.rb
RSpec.describe Comment, type: :model do
    # Test validation for text presence
    context 'Validations' do
      it "is valid with valid attributes" do
          task = create(:task) # This will use the user factory with a unique email
          comment = build(:comment, task: task)
          expect(comment).to be_valid
        end
      
        it "is not valid without text" do
          task = create(:task)
          comment = build(:comment, task: task, text: nil)
          expect(comment).to_not be_valid
        end
      
        it "is valid without an image" do
          task = create(:task)
          comment = build(:comment, task: task, image: nil)
          expect(comment).to be_valid
        end
    end
  
    # Soft delete tests
    describe 'Soft delete' do
      let!(:user) { create(:user, email: "unique_user@example.com") }
      let!(:comment) { create(:comment, user: user) }
    
      it 'soft deletes a comment' do
        comment.destroy  # Using destroy method provided by acts_as_paranoid
        expect(comment.reload.deleted_at).not_to be_nil
      end
    
      it 'restores a comment' do
        comment.destroy  # Using destroy method provided by acts_as_paranoid
        comment.restore
        expect(comment.reload.deleted_at).to be_nil
      end
    end
end
  