require 'rails_helper'

RSpec.describe "Comments", type: :request do
  # Create a user, task, and comment for testing
  let!(:user) { create(:user) }
  let!(:task) { create(:task, user: user) }
  let!(:comment) { create(:comment, task: task, user: user) }
  
  # Authentication headers for the user
  let(:auth_headers) { authenticated_headers(user) }

  describe 'POST /api/v1/tasks/:id/comments' do
    context 'when task exists' do
      it 'creates a new comment for the task' do
        # Define valid attributes for the new comment
        valid_attributes = { comments: [{ text: 'New comment text' }], task_id: task.id }

        # Make the POST request to create a new comment
        post "/api/v1/tasks/#{task.id}/comments", params: valid_attributes, headers: auth_headers

        # Expect a successful response and check the returned message and comment text
        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Comments created successfully')
        expect(json['comments'].first['text']).to eq('New comment text')
        expect(Comment.last.user_id).to eq(user.id)  # Check that the comment is associated with the correct user
      end
    end
    
    context 'when task does not exist' do
      it 'returns an error' do
        # Attempt to create a comment for a non-existent task
        post "/api/v1/tasks/99999/comments", params: { comment: { text: 'Invalid task comment' } }, headers: auth_headers

        # Expect a not found response with the correct error message
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Task not found')
      end
    end
  end  

  describe 'DELETE /api/v1/comments/:id' do
    context 'when the comment exists and belongs to the current user' do
      it 'deletes the comment' do
        # Make a DELETE request to remove the comment
        delete "/api/v1/comments/#{comment.id}", headers: auth_headers

        # Expect a successful response and check the returned message
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Comment deleted successfully')
      end
    end

    context 'when the comment exists but does not belong to the current user' do
      before do
        # Create another user for testing
        other_user = create(:user)  
        
        # Simulate the current_user being other_user
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)  
      end
      
      it 'returns a 403 forbidden status' do
        # Attempt to delete a comment by another user
        delete "/api/v1/comments/#{comment.id}", headers: auth_headers  

        # Expect a forbidden response with the correct error message
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')  
      end      
    end

    context 'when the comment does not exist' do
      it 'returns a not found error' do
        # Attempt to delete a non-existent comment
        delete '/api/v1/comments/99999', headers: auth_headers

        # Expect a not found response with the correct error message
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Comment not found')
      end
    end
  end

  describe 'PUT /api/v1/comments/:id' do
    context 'when the comment exists and belongs to the current user' do
      it 'updates the comment' do
        # Define valid attributes for the updated comment
        valid_attributes = { comments: [{ text: 'Updated comment text' }], task_id: task.id }

        # Make a PUT request to update the comment
        put "/api/v1/comments/#{comment.id}", params: valid_attributes, headers: auth_headers

        # Expect a successful response and check the returned message
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Comment updated successfully')
        expect(comment.reload.text).to eq('Updated comment text')  # Verify the comment has been updated
      end
    end

    context 'when the comment exists but does not belong to the current user' do
      let!(:valid_attributes) { { comment: { text: 'Unauthorized update' } } }

      before do
        # Create another user for testing
        other_user = create(:user) 
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)  # Simulate the current_user being other_user
      end

      it 'returns a 403 forbidden status' do
        # Attempt to update the comment by another user
        put "/api/v1/comments/#{comment.id}", params: valid_attributes, headers: auth_headers  

        # Expect a forbidden response with the correct error message
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')  
      end
    end

    context 'when the comment does not exist' do
      it 'returns a not found error' do
        # Attempt to update a non-existent comment
        put '/api/v1/comments/99999', params: { comment: { text: 'Non-existing comment' } }, headers: auth_headers

        # Expect a not found response with the correct error message
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Comment not found')
      end
    end
  end

  describe 'GET /api/v1/comments' do
    context 'when comments exist' do
      it 'returns all comments' do
        # Clean the database before creating new comments
        Comment.delete_all  
        create_list(:comment, 5)  # Create a list of comments

        # Make a GET request to fetch comments
        get '/api/v1/comments', params: { page: 1, per_page: 10 }, headers: auth_headers

        # Expect a successful response and check the number of comments returned
        expect(response).to have_http_status(:ok)
        expect(json['comments'].size).to eq(5)
      end
    end

    context 'when no comments exist' do
      before do
        Comment.delete_all  # Clean the database
      end
      
      it 'returns an empty array' do
        # Make a GET request to fetch comments when none exist
        get '/api/v1/comments', params: { page: 1, per_page: 10 }, headers: auth_headers

        # Expect a successful response with an empty comments array
        expect(response).to have_http_status(:ok)
        expect(json['comments']).to be_empty
      end
    end
  end 
end
