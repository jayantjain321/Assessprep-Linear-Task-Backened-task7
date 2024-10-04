require 'rails_helper'

RSpec.describe  "Comments", type: :request do
  let!(:user) { create(:user) }
  let!(:task) { create(:task, user: user) }
  let!(:comment) { create(:comment, task: task, user: user) }
  let(:auth_headers) { authenticated_headers(user) }

  describe 'POST /api/v1/tasks/:id/comments' do
    context 'when task exists' do
      it 'creates a new comment for the task' do
        valid_attributes = { comment: { text: 'New comment text' }, task_id: task.id }

        # Notice the use of params: and headers as part of options
        post "/api/v1/tasks/#{task.id}/comments", params: valid_attributes, headers: auth_headers

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Comment created successfully')
        expect(json['comment']['text']).to eq('New comment text')
        expect(Comment.last.user_id).to eq(user.id)
      end
    end
    context 'when task does not exist' do
      it 'returns an error' do
        post "/api/v1/tasks/99999/comments", params: { comment: { text: 'Invalid task comment' } },  headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Task not found')
      end
    end
  end  
  describe 'DELETE /api/v1/comments/:id' do
    context 'when the comment exists and belongs to the current user' do
      it 'deletes the comment' do
        delete "/api/v1/comments/#{comment.id}", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Comment deleted successfully')
      end
    end

    context 'when the comment exists but does not belong to the current user' do
      before do
        other_user = create(:user)  # Create a user who will be used as the current_user
    
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)  # Simulate the current_user being other_user
      end
      
      it 'returns a 403 forbidden status' do
        delete "/api/v1/comments/#{comment.id}", headers: auth_headers  # Attempt to delete by another user
      
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')  # Correct error message
      end
      
    end

    context 'when the comment does not exist' do
      it 'returns a not found error' do
        delete '/api/v1/comments/99999', headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Comment not found')
      end
    end
  end
  describe 'PUT /api/v1/comments/:id' do
    context 'when the comment exists and belongs to the current user' do
      it 'updates the comment' do
        valid_attributes = { comment: { text: 'Updated comment text' } }

        put "/api/v1/comments/#{comment.id}", params: valid_attributes, headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Comment updated successfully')
        expect(comment.reload.text).to eq('Updated comment text')
      end
    end

    context 'when the comment exists but does not belong to the current user' do
        let!(:valid_attributes) { { comment: { text: 'Unauthorized update' } } }

        before do
            other_user = create(:user) 
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)  # Simulate the current_user being other_user
        end

        it 'returns a 403 forbidden status' do
            delete "/api/v1/comments/#{comment.id}", params: valid_attributes, headers: auth_headers  # Attempt to delete by another user

            expect(response).to have_http_status(:forbidden)
            expect(json['error']).to eq('You are not authorized to perform this action')  # Correct error message
        end
    end

    context 'when the comment does not exist' do
      it 'returns a not found error' do
        put '/api/v1/comments/99999', params: { comment: { text: 'Non-existing comment' } }, headers: auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Comment not found')
      end
    end
  end
  describe 'GET /api/v1/comments' do
    context 'when comments exist' do
      it 'returns all comments' do
        Comment.delete_all  # Clean the database before creating new comments
        create_list(:comment, 5)
        get '/api/v1/comments', params: { page: 1, per_page: 10 }, headers: auth_headers
  
        expect(response).to have_http_status(:ok)
        expect(json['comments'].size).to eq(5)
      end
    end
  
    context 'when no comments exist' do
      before do
        Comment.delete_all
      end
      it 'returns an empty array' do
        get '/api/v1/comments', params: { page: 1, per_page: 10 }, headers: auth_headers
  
        expect(response).to have_http_status(:ok)
        expect(json['comments']).to be_empty
      end
    end
  end 
end
  
  
